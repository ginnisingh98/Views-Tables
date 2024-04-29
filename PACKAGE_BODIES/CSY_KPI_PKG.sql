--------------------------------------------------------
--  DDL for Package Body CSY_KPI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSY_KPI_PKG" as
/* $Header: csykpib.pls 115.16 2004/07/30 21:14:09 smisra noship $ */
function get_agents_time(p_resource_id number,
                        p_start_date date,
                        p_end_date date) return number is
    lp_cnt       number;
    j            number;
    l_msg_index_out number;
    x_ret_stat   varchar2(2000);
    x_msg_count  number;
    x_msg_data   varchar2 (2000);
    x_shifts     jtf_calendar_pub_24hr.shift_tbl_type;
    l_total_time number ;
    l_dt1        date;
    l_dt2        date;
begin
  l_total_time := 0;
  -- no need to return negative number
  if (p_end_date <= p_start_date) then
     return 0;
  end if;
  jtf_calendar_pub_24hr.get_resource_shifts(1,fnd_api.g_false,p_resource_id,
                                            'RS_EMPLOYEE',
                                            p_start_date, p_end_date,
                                            x_ret_stat,
                                            x_msg_count,
                                            x_msg_data,
                                            x_shifts);
   /*
   --dbms_output.put_line('Return Status :'||x_ret_stat || ':');
   --dbms_output.put_line('Return Message:'||x_msg_data || ':');
   IF (FND_MSG_PUB.Count_Msg > 1) THEN
      --Display all the error messages
      FOR j in  1..FND_MSG_PUB.Count_Msg LOOP
        FND_MSG_PUB.Get(p_msg_index=>j,
                        p_encoded=>'F',
                        p_data=>x_msg_data,
                        p_msg_index_out=>l_msg_index_out);
        DBMS_OUTPUT.PUT_LINE(x_msg_data);
      END LOOP;
    ELSE
      --Only one error
      FND_MSG_PUB.Get(p_msg_index=>1,
                      p_encoded=>'F',
                      p_data=>x_msg_data,
                      p_msg_index_out=>l_msg_index_out);
      DBMS_OUTPUT.PUT_LINE(x_msg_data);

   END IF;
   */
   l_total_time := 0;
   if (x_ret_stat = fnd_api.g_ret_sts_success) then
   for lp_cnt in 1..x_shifts.count loop
      /*
      dbms_output.put_line('Start Dt:'||
                to_char(x_shifts(lp_cnt).start_time,'dd-mon-yyyy hh24:mi:ss')||
                           ' End Time:' ||
                to_char(x_shifts(lp_cnt).end_time,'dd-mon-yyyy hh24:mi:ss'));
       */
       -- get max of p_start_date and shifts.start_time
       if (p_start_date > x_shifts(lp_cnt).start_time) then
          l_dt1 := p_start_date;
       else
          l_dt1 := x_shifts(lp_cnt).start_time;
       end if;
       -- get min of p_end_date and shifts.end_time
       if (p_end_date > x_shifts(lp_cnt).end_time) then
          l_dt2 := x_shifts(lp_cnt).end_time;
       else
          l_dt2 := p_end_date;
       end if;
       --l_dt1 := greatest(p_start_date,x_shifts(lp_cnt).start_time);
       --l_dt2 := least   (p_end_date,x_shifts(lp_cnt).end_time);
       /* 10/14/03 10:40cst
          if condition is used to handle mismatch between shift data and
          incident response/resolution dates. support between 10/1 to 10/10
          agent's shift times are 10/4/ 9am to 5pm and 10/5 9 to 5 and so on.
          But somehow agent resolves an incident on 10/3, in that case l_dt2 will
          point to 10/3 but l_dt1 will point to 10/4 9am(begining of shift
          during that period. so effectively, time taken to resolve is zero
       */
       if (l_dt2 >= l_dt1) then
          l_total_time := l_total_time + l_dt2 - l_dt1;
       end if;
   end loop;
   else l_total_time := p_end_date - p_start_date;
   end if;
   return l_total_time;
end;
-----------------------------------------
procedure upload_resp_and_resl(p_summary_date date,
                               p_incident_owner_id       number,
                               p_owner_group_id          number,
                               p_incident_severity_id             number,
                               p_owner_type              varchar2,
                               p_response_time           number ,
                               p_requests_responded      number ,
                               p_wait_on_agent_resp      number ,
                               p_wait_on_others_resp     number ,
                               p_requests_resolved       number ,
                               p_resolve_time            number ,
                               p_wait_on_agent_resl      number ,
                               p_wait_on_int_org_resl    number ,
                               p_wait_on_ext_org_resl    number ,
                               p_wait_on_support_resl    number ,
                               p_wait_on_customer_resl   number ,
                               p_resp_sla_missed         number ,
                               p_resl_sla_missed         number ,
                               p_beginning_backlog       number ,
                               p_ending_backlog          number ,
                               p_sr_assigned             number ,
                               p_sr_reassigned_to_others number ) is
begin
    update csy_response_resolutions
       set
           total_response_time  = nvl(total_response_time,0)+
                                            nvl(p_response_time,0),
           total_requests_responded = nvl(total_requests_responded,0)+
                                            nvl(p_requests_responded,0),
           total_wait_on_agent_resp = nvl(total_wait_on_agent_resp,0) +
                                        nvl(p_wait_on_agent_resp,0),
           total_wait_on_others_resp = nvl(total_wait_on_others_resp,0) +
                                        nvl(p_wait_on_others_resp,0),
           total_requests_resolved = nvl(total_requests_resolved,0)+
                                            nvl(p_requests_resolved,0),
           total_resolve_time  = nvl(total_resolve_time,0)+
                                            nvl(p_resolve_time,0),
           total_wait_on_agent_resl = nvl(total_wait_on_agent_resl,0) +
                                        nvl(p_wait_on_agent_resl,0),
           total_wait_on_int_org_resl = nvl(total_wait_on_int_org_resl,0) +
                                        nvl(p_wait_on_int_org_resl,0),
           total_wait_on_ext_org_resl = nvl(total_wait_on_ext_org_resl,0) +
                                        nvl(p_wait_on_ext_org_resl,0),
           total_wait_on_support_resl = nvl(total_wait_on_support_resl,0) +
                                        nvl(p_wait_on_support_resl,0),
           total_wait_on_customer_resl = nvl(total_wait_on_customer_resl,0) +
                                        nvl(p_wait_on_customer_resl,0),
           total_resp_sla_missed = nvl(total_resp_sla_missed,0) +
                                        nvl(p_resp_sla_missed,0),
           total_resl_sla_missed = nvl(total_resl_sla_missed,0) +
                                        nvl(p_resl_sla_missed,0),
           beginning_backlog = nvl(p_beginning_backlog,beginning_backlog), --backlog is calculated afresh
           ending_backlog = nvl(p_ending_backlog,ending_backlog), -- so no need to add to existing value
           total_sr_assigned = nvl(total_sr_assigned,0)+p_sr_assigned,
           total_sr_reassigned_to_others = nvl(total_sr_reassigned_to_others,0)+
                                            nvl(p_sr_reassigned_to_others,0)
     where summary_date         = p_summary_date
       and incident_owner_id    = p_incident_owner_id
       and owner_group_id       = p_owner_group_id
       and owner_type           = p_owner_type
       and incident_severity_id = p_incident_severity_id;
    if (sql%notfound) then
       insert into csy_response_resolutions
              (summary_date,
               incident_owner_id,
               incident_severity_id,
               owner_group_id,
               owner_type,
               TOTAL_RESPONSE_TIME           ,
               TOTAL_REQUESTS_RESPONDED      ,
               TOTAL_WAIT_ON_AGENT_RESP      ,
               TOTAL_WAIT_ON_OTHERS_RESP     ,
               TOTAL_REQUESTS_RESOLVED       ,
               TOTAL_RESOLVE_TIME            ,
               TOTAL_WAIT_ON_AGENT_RESL      ,
               TOTAL_WAIT_ON_INT_ORG_RESL    ,
               TOTAL_WAIT_ON_EXT_ORG_RESL    ,
               TOTAL_WAIT_ON_SUPPORT_RESL    ,
               TOTAL_WAIT_ON_CUSTOMER_RESL   ,
               TOTAL_RESP_SLA_MISSED         ,
               TOTAL_RESL_SLA_MISSED         ,
               BEGINNING_BACKLOG             ,
               ENDING_BACKLOG                ,
               TOTAL_SR_ASSIGNED             ,
               TOTAL_SR_REASSIGNED_TO_OTHERS ,
               last_update_date              ,
               last_updated_by               ,
               creation_date                 ,
               created_by                    ,
               last_update_login             ,
               program_id                    ,
               program_login_id              ,
               program_application_id        ,
               request_id
               )
       values (p_summary_date,
               p_incident_owner_id,
               p_incident_severity_id,
               p_owner_group_id,
               p_owner_type,
               p_response_time           ,
               p_requests_responded      ,
               p_wait_on_agent_resp      ,
               p_wait_on_others_resp     ,
               p_requests_resolved       ,
               p_resolve_time            ,
               p_wait_on_agent_resl      ,
               p_wait_on_int_org_resl    ,
               p_wait_on_ext_org_resl    ,
               p_wait_on_support_resl    ,
               p_wait_on_customer_resl   ,
               p_resp_sla_missed         ,
               p_resl_sla_missed         ,
               p_beginning_backlog       ,
               p_ending_backlog          ,
               p_sr_assigned             ,
               p_sr_reassigned_to_others ,
               sysdate                       ,
               g_user_id                     ,
               sysdate                       ,
               g_user_id                     ,
               g_login_user_id               ,
               g_conc_program_id             ,
               g_conc_login_id               ,
               g_conc_appl_id                ,
               g_conc_request_id
              );
    end if;
end;
----------------------
procedure debug(l_msg varchar2) is
  l_tmp varchar2(4000);
begin
 /*
 if (length(l_msg) > 4000) then
    l_tmp := substr(l_msg,1,4000);
    insert into biv_debug(message, report_id,seq_no) values (
       l_tmp, 'XX', g_seq);
    g_seq := g_seq + 1;
    --
    l_tmp := substr(l_msg,4001,4000);
    insert into biv_debug(message, report_id,seq_no) values (
       l_tmp, 'XX', g_seq);
 else
    insert into biv_debug(message, report_id,seq_no) values (
       l_msg, 'XX', g_seq);
 end if;
 fnd_file.put_line(fnd_file.log,'Message No:'||to_char(g_seq) ||
                   ' =====================================================');
 fnd_file.put_line(fnd_file.log,l_msg);
 */
 g_seq := g_seq + 1;
end;
procedure get_sr_backlog          (p_from_date in date,
                                   p_to_date   in date) is
 x number;
 l_dt date;
 cursor c_backlog is
         select nvl(aud_out.incident_owner_id,-1), nvl(aud_out.group_id,-1),
                nvl(aud_out.incident_severity_id,-1), count(*)
          from cs_incidents_audit_b aud_out,
               cs_incidents_all_b sr
         where aud_out.incident_resolved_date is null
           and aud_out.incident_id = sr.incident_id
           and nvl(sr.incident_resolved_date,sysdate+1000) > l_dt
           and incident_audit_id =
           /* supposr conc program dates are 11/15 to 12/15
              a SR was resolved on 12/10 for last time
              was in resolved state from 11/1/ to 11/25
              on 11/26 it was set to unresolved
              for every date from 11/15 to 11/25, this query will find audit record
              with NOT NULL incident_resolved date and hence it will not be counted as
              Backlog
              for l_dt = 11/26, it will find auidt rec with NULL incident_resolved_date
              so for 11/26, it will be counted as BACKLOG
              same thing will be applicable from 11/27 to 12/9 as incident was again set to
              resolved on 12/10
           ***/
           /* why are we using subquery here? couldn't we just use the
              above statement to figure out backlog?
              Ans: No. suppose l_dt is 10-may-03, close_date is 30-may-03
              it does not mean that this SR was backlog from 10 to 29th may
              reason: it might be closed between 11-may to 25th may.
              so it is not a backlog between those dates. It is the
              subquery that will return a record representing closed SR for
              all dates between 11th and 25th may and aut_out.status_flag = 'O'
              will make it unselected and hence not counted
           */
                (select max(incident_audit_id)
                 from cs_incidents_audit_b aud_in
                where aud_in.incident_id = aud_out.incident_id
                  and aud_in.creation_date < l_dt +1)
                  -- so that full day is taken
         group by aud_out.incident_owner_id,
                  aud_out.group_id,
                  aud_out.incident_severity_id;
  Type number_table_type   is table of number index by binary_integer;
  l_owner_arr   number_table_type;
  l_group_arr   number_table_type;
  l_sev_arr     number_table_type;
  l_backlog_arr number_table_type;
  l_end_date    date;
begin
  l_dt := trunc(p_from_date);
  l_end_date := trunc(p_to_date);
  --dbms_output.put_line('From date:'||to_char(p_from_date,'dd-mon-yyyy hh24:mi:ss'));
  --dbms_output.put_line('To   date:'||to_char(p_to_date,'dd-mon-yyyy hh24:mi:ss'));
  --dbms_output.put_line('End  date:'||to_char(l_end_date,'dd-mon-yyyy hh24:mi:ss'));
  -- These 2 updaes are needed because if backlog is reduced to 0 then c_backlog
  -- cursor will not return any row and existing value will not be overwritten
  update csy_response_resolutions
     set ending_backlog = 0
   where summary_date between trunc(p_from_date) and trunc(p_to_date);
  update csy_response_resolutions
     set beginning_backlog = 0
   where summary_date between trunc(p_from_date+1) and trunc(p_to_date+1);
  loop
      if (l_dt > l_end_date ) then exit; end if;
      open c_backlog;
      fetch c_backlog bulk collect into l_owner_arr, l_group_arr,
                                        l_sev_arr, l_backlog_arr;
      close c_backlog;
      if (l_owner_arr.count > 0) then
      for j in l_owner_arr.first..l_owner_arr.last loop
         upload_resp_and_resl(p_incident_owner_id    =>l_owner_arr(j),
                         p_owner_group_id       => l_group_arr(j),
                         p_incident_severity_id => l_Sev_arr(j),
                         p_summary_date         => l_dt,
                         p_owner_type           => 'A',
 p_response_time           => 0,
 p_requests_responded      => 0,
 p_wait_on_agent_resp      => 0,
 p_wait_on_others_resp     => 0,
 p_requests_resolved       => 0,
 p_resolve_time            => 0,
 p_wait_on_agent_resl      => 0,
 p_wait_on_int_org_resl    => 0,
 p_wait_on_ext_org_resl    => 0,
 p_wait_on_support_resl    => 0,
 p_wait_on_customer_resl   => 0,
 p_resp_sla_missed         => 0,
 p_resl_sla_missed         => 0,
 p_beginning_backlog       => null,
 p_sr_assigned             => 0,
 p_sr_reassigned_to_others => 0,
                         p_ending_backlog       => l_backlog_arr(j));
         upload_resp_and_resl(p_incident_owner_id    =>l_owner_arr(j),
                         p_owner_group_id       => l_group_arr(j),
                         p_incident_severity_id => l_Sev_arr(j),
                         p_summary_date         => l_dt+1,
                         p_owner_type           => 'A',
 p_response_time           => 0,
 p_requests_responded      => 0,
 p_wait_on_agent_resp      => 0,
 p_wait_on_others_resp     => 0,
 p_requests_resolved       => 0,
 p_resolve_time            => 0,
 p_wait_on_agent_resl      => 0,
 p_wait_on_int_org_resl    => 0,
 p_wait_on_ext_org_resl    => 0,
 p_wait_on_support_resl    => 0,
 p_wait_on_customer_resl   => 0,
 p_resp_sla_missed         => 0,
 p_resl_sla_missed         => 0,
 p_ending_backlog          => null,
 p_sr_assigned             => 0,
 p_sr_reassigned_to_others => 0,
                         p_beginning_backlog    => l_backlog_arr(j));
      end loop;
      end if;
      --dbms_output.put_line('Backlog Date:'|| to_char(l_dt,'dd-mon-yyyy hh24:mi:ss'));
      l_dt := l_dt + 1;
  end loop;
end get_sr_backlog;
------------------------------------------------------
procedure get_resolution_timings  (p_from_date in date,
                                   p_to_date   in date) is
  --
  --
  /* we need separate cursor for timings and number of resolutions because
     one query will not work due to determination of RESL_SLA_MISSED
     same thing is applicable to response timings too
  */
  --
  l_dt date ;
  l_sql   varchar2(4000);
  cursor c_resolutions is
    select nvl(aud.incident_owner_id,-1)     incident_owner_id,
           nvl(aud.incident_severity_id,-1)  incident_severity_id,
           nvl(aud.group_id,-1)              owner_group_id,
           trunc(aud.incident_resolved_date) incident_resolved_date,
           count(aud.incident_id) resolutions,
           count(decode(sign(sr.incident_resolved_date-
                             sr.expected_resolution_date),
                        1,1,null)) resl_sla_missed
          from cs_incidents_audit_b aud,      --this is audit rec for response
              cs_incidents_all_b    sr
         where sr.incident_id = aud.incident_id
           and (aud.incident_owner_id is not null or
                    aud.group_id is not null)
           and aud.incident_audit_id =
                   ( select max(incident_audit_id)
                       from cs_incidents_audit_b aud_in
                      where aud_in.incident_id = aud.incident_id
                        and aud_in.creation_date between p_from_date
                                                     and p_to_date
                        and nvl(aud_in.old_incident_resolved_date,l_dt) <>
                                                   nvl(aud_in.incident_resolved_date,l_dt)
                        and aud_in.incident_resolved_date is not null
                        -- above cond is needed to make sure that sr is
                        -- responded. if this cond is not there then incident_resolved_date
                        -- as null to may get selected which is clearly not
                        -- responded condition.
                   )
         -- above query will insure that selected response is the last response
         group by aud.incident_owner_id,
                  aud.group_id,
                  aud.incident_severity_id,
                  trunc(aud.incident_resolved_date);
  cursor c_resolutions_rev is
    select /*+ ORDERED */
           nvl(prev_resp.incident_owner_id,-1)   incident_owner_id,
           nvl (prev_resp.incident_severity_id,-1) incident_severity_id,
           nvl (prev_resp.group_id,-1)             owner_group_id,
           trunc(prev_resp.incident_resolved_date)             incident_resolved_date,
           count(prev_resp.incident_id) resolutions,
           count(decode(sign(sr.actual_resolution_date-
                             sr.expected_resolution_date),
                        1,1,null)) resl_sla_missed
          from cs_incidents_audit_b curr_resp,
                    --this is audit rec for response in curr run dates
               cs_incidents_audit_b prev_resp,
                    -- this is response in before curr run dates
              cs_incidents_all_b sr
         where sr.incident_id = prev_resp.incident_id
           and curr_resp.incident_audit_id =
                   ( select max(incident_audit_id)
                       from cs_incidents_audit_b aud_in
                      where aud_in.incident_id = curr_resp.incident_id
                        and aud_in.creation_date between p_from_date
                                                     and p_to_date
                        and nvl(aud_in.old_incident_resolved_date,l_dt) <>
                                                   nvl(aud_in.incident_resolved_date,l_dt)
                        and aud_in.incident_resolved_date is not null
                        -- above cond is needed to make sure that sr is
                        -- responded. if this cond is not there then incident_resolved_date
                        -- as null to may get selected which is clearly not
                        -- responded condition.
                   )
         -- above query will insure that selected response is the last response
           and prev_resp.incident_id = curr_resp.incident_id
           and prev_resp.incident_audit_id = ( select max(incident_audit_id)
                       from cs_incidents_audit_b aud_in1
                      where aud_in1.incident_id = curr_resp.incident_id
                        and aud_in1.creation_date < p_from_date
                        and nvl(aud_in1.old_incident_resolved_date,l_dt) <>
                                                   nvl(aud_in1.incident_resolved_date,l_dt)
                        and aud_in1.incident_resolved_date is not null
                        -- above cond is needed to make sure that sr is
                        -- responded. if this cond is not there then incident_resolved_date
                        -- as null to may get selected which is clearly not
                        -- responded condition.
                   )
         group by prev_resp.incident_owner_id,
                  prev_resp.group_id,
                  prev_resp.incident_severity_id,
                  trunc(prev_resp.incident_resolved_date);
  cursor c_resl_times is
    select /*+ ORDERED */
           nvl(aud.incident_owner_id,-1)   incident_owner_id,
           nvl (aud.incident_severity_id,-1) incident_severity_id,
           nvl (aud.group_id,-1)             owner_group_id,
           trunc(aud.incident_resolved_date)             incident_resolved_date,
           sum(decode(aud.incident_owner_id, to_dttm.old_incident_owner_id,
             --   decode(to_stat.status_class_code,'WAIT_ON_SUPPORT',
             -- above decode is removed on 17-dec-03. resl time as per SRD
                   csy_kpi_pkg.get_agents_time(
                     aud.incident_owner_id,
                     decode(from_dttm.old_incident_date,null,from_dttm.incident_date,from_dttm.creation_date),
                     decode(aud.incident_audit_id,to_dttm.incident_audit_id,
                        aud.incident_resolved_date,to_dttm.creation_date)
                   )/*,0)*/,0)
              )                                * 1440          resl_time      ,
           -- we need to select distinct because each responded
           -- audit will be joined with mulitple from and to aduit record
           -- no need to get count, it is obtained in prev qry 10/15/03
           --count(distinct aud.incident_id) responses,
           sum( decode(to_stat.status_class_code,'WAIT_ON_SUPPORT',
                     decode(aud.incident_audit_id,to_dttm.incident_audit_id,
                        aud.incident_resolved_date,to_dttm.creation_date)
                           -decode(from_dttm.old_incident_date,null,from_dttm.incident_date,from_dttm.creation_date),0)
              )                                * 1440          wait_on_support,
           sum(decode(to_stat.status_class_code,'WAIT_ON_CUSTOMER',
                     decode(aud.incident_audit_id,to_dttm.incident_audit_id,
                        aud.incident_resolved_date,to_dttm.creation_date)
                           -decode(from_dttm.old_incident_date,null,from_dttm.incident_date,from_dttm.creation_date),0))
                                               * 1440         wait_on_customer,
           sum(decode(to_stat.status_class_code,'WAIT_ON_INT_GROUP',
                     decode(aud.incident_audit_id,to_dttm.incident_audit_id,
                        aud.incident_resolved_date,to_dttm.creation_date)
                           -decode(from_dttm.old_incident_date,null,from_dttm.incident_date,from_dttm.creation_date),0))
                                               * 1440          wait_on_int_org,
           sum(decode(to_stat.status_class_code,'WAIT_ON_EXT_GROUP',
                     decode(aud.incident_audit_id,to_dttm.incident_audit_id,
                        aud.incident_resolved_date,to_dttm.creation_date)
                           -decode(from_dttm.old_incident_date,null,from_dttm.incident_date,from_dttm.creation_date),0))
                                               * 1440          wait_on_ext_org,
           /* in a period between from_dttm and to_dttm, who is owns the
             service request? from_dttm.incident_owner_id. we could have used
             to_dttm.old_incident_owner_id but if there is no change in owner
             then old_incident_owner will be null. in that case we have to
             use nvl(to_dttm.old_incident_owner_id, to_dttm.incident_owner_id).
           */
           sum(decode(from_dttm.incident_owner_id,aud.incident_owner_id,
                        decode(to_stat.status_class_code,'WAIT_ON_SUPPORT',
                     decode(aud.incident_audit_id,to_dttm.incident_audit_id,
                        aud.incident_resolved_date,to_dttm.creation_date)
                           -decode(from_dttm.old_incident_date,null,from_dttm.incident_date,from_dttm.creation_date),0))
              ) * 1440 wait_on_agent
          from cs_incidents_audit_b aud      , --this is audit rec for response
               cs_incidents_audit_b to_dttm  , -- to date time
               cs_incidents_audit_b from_dttm, -- from date time
               cs_incident_Statuses_b to_stat
  /* the pair of from_dttm to to_dttm will give the durating in which an agent
     owned a serveice request.
               cs_incidents_all_b   sr -- only for incident_date */
         where aud.incident_audit_id =
                   ( select max(incident_audit_id)
                       from cs_incidents_audit_b aud_in
                      where aud_in.incident_id = aud.incident_id
                        and aud_in.creation_date between p_from_date
                                                     and p_to_date
                        and nvl(aud_in.old_incident_resolved_date,l_dt) <>
                                                   nvl(aud_in.incident_resolved_date,l_dt)
                        and aud_in.incident_resolved_date is not null
                        -- above cond is needed to make sure that sr is
                        -- responded. if this cond is not there then incident_resolved_date
                        -- as null to may get selected which is clearly not
                        -- responded condition.
                   )
         -- above query will insure that selected response is the last response
           and to_dttm.incident_id        = aud.incident_id
           and to_dttm.creation_date     <= aud.creation_date
           and to_dttm.old_incident_status_id = to_stat.incident_status_id
           and (to_dttm.incident_audit_id = aud.incident_audit_id or
                ((nvl(to_dttm.old_incident_owner_id,-1) <>
                                           nvl(to_dttm.incident_owner_id,-1) or
                nvl(to_dttm.old_incident_status_id,-1) <>
                                           nvl(to_dttm.incident_status_id,-1)) and
                to_dttm.creation_date >= to_dttm.incident_date)
               )
           -- above will insure that to_dttm start from responded audit rec
           and to_dttm.incident_id = from_dttm.incident_id
           /*
           and (nvl(from_dttm.old_incident_owner_id,-1) <>
                                           nvl(from_dttm.incident_owner_id,-1)
           or  nvl(from_dttm.old_incident_status_id,-1) <>
                                           nvl(from_dttm.incident_status_id,-1))
           */
           and from_dttm.incident_audit_id =
                   (select max(incident_audit_id) from cs_incidents_audit_b x
                     where x.incident_id = aud.incident_id
                       and ((nvl(x.old_incident_owner_id,-1) <>
                                       nvl(x.incident_owner_id,-1) or
                            nvl(x.old_incident_status_id,-1) <>
                                       nvl(x.incident_status_id,-1)) and
                            x.creation_date >= x.incident_date
                           )
                       and x.creation_date < to_dttm.creation_date
                   )
         group by aud.incident_owner_id,
                  aud.group_id,
                  aud.incident_severity_id,
                  trunc(aud.incident_resolved_date)
        ;
  cursor c_resl_times_rev is
    select /*+ ORDERED */
           nvl(aud.incident_owner_id,-1)   incident_owner_id,
           nvl (aud.incident_severity_id,-1) incident_severity_id,
           nvl (aud.group_id,-1)             owner_group_id,
           trunc(aud.incident_resolved_date)             incident_resolved_date,
           sum(decode(aud.incident_owner_id, to_dttm.old_incident_owner_id,
             --   decode(to_stat.status_class_code,'WAIT_ON_SUPPORT',
             -- 17-dec-03 above decode removed to make it as per SRD
                   csy_kpi_pkg.get_agents_time(
                     aud.incident_owner_id,
                     decode(from_dttm.old_incident_date,null,from_dttm.incident_date,from_dttm.creation_date),
                     decode(aud.incident_audit_id,to_dttm.incident_audit_id,
                        aud.incident_resolved_date,to_dttm.creation_date)
                   )/*,0)*/,0)
              )                                * 1440          resl_time      ,
           -- we need to select distinct because each responded
           -- audit will be joined with mulitple from and to aduit record
           -- 10/15/2003 count(distinct aud.incident_id) responses,
           sum(decode(to_stat.status_class_code,'WAIT_ON_SUPPORT',
                     decode(aud.incident_audit_id,to_dttm.incident_audit_id,
                        aud.incident_resolved_date,to_dttm.creation_date)
                           -decode(from_dttm.old_incident_date,null,from_dttm.incident_date,from_dttm.creation_date),0))
                                               * 1440          wait_on_support,
           sum(decode(to_stat.status_class_code,'WAIT_ON_CUSTOMER',
                     decode(aud.incident_audit_id,to_dttm.incident_audit_id,
                        aud.incident_resolved_date,to_dttm.creation_date)
                           -decode(from_dttm.old_incident_date,null,from_dttm.incident_date,from_dttm.creation_date),0))
                                               * 1440         wait_on_customer,
           sum(decode(to_stat.status_class_code,'WAIT_ON_INT_GROUP',
                     decode(aud.incident_audit_id,to_dttm.incident_audit_id,
                        aud.incident_resolved_date,to_dttm.creation_date)
                           -decode(from_dttm.old_incident_date,null,from_dttm.incident_date,from_dttm.creation_date),0))
                                               * 1440          wait_on_int_org,
           sum(decode(to_stat.status_class_code,'WAIT_ON_EXT_GROUP',
                     decode(aud.incident_audit_id,to_dttm.incident_audit_id,
                        aud.incident_resolved_date,to_dttm.creation_date)
                           -decode(from_dttm.old_incident_date,null,from_dttm.incident_date,from_dttm.creation_date),0))
                                               * 1440          wait_on_ext_org,
           sum(decode(from_dttm.incident_owner_id,aud.incident_owner_id,
                        decode(to_stat.status_class_code,'WAIT_ON_SUPPORT',
                     decode(aud.incident_audit_id,to_dttm.incident_audit_id,
                        aud.incident_resolved_date,to_dttm.creation_date)
                           -decode(from_dttm.old_incident_date,null,from_dttm.incident_date,from_dttm.creation_date),0))
              ) * 1440 wait_on_agent
          from cs_incidents_audit_b curr_resp,
               cs_incidents_audit_b aud      , --this is audit rec for prior resolutions
               cs_incidents_audit_b to_dttm  , -- to date time
               cs_incidents_audit_b from_dttm, -- from date time
               cs_incident_statuses_b to_Stat
  /* the pair of from_dttm to to_dttm will give the durating in which an agent
     owned a serveice request.
               cs_incidents_all_b   sr -- only for incident_date */
         where aud.incident_audit_id =
                   ( select max(incident_audit_id)
                       from cs_incidents_audit_b aud_in
                      where aud_in.incident_id = curr_resp.incident_id
                        and aud_in.creation_date < p_from_date
                        and nvl(aud_in.old_incident_resolved_date,l_dt) <>
                                                   nvl(aud_in.incident_resolved_date,l_dt)
                        and aud_in.incident_resolved_date is not null
                        -- above cond is needed to make sure that sr is
                        -- responded. if this cond is not there then incident_resolved_date
                        -- as null to may get selected which is clearly not
                        -- responded condition.
                   )
           and curr_resp.incident_audit_id =
                   ( select max(incident_audit_id)
                       from cs_incidents_audit_b aud_in
                      where aud_in.incident_id = curr_resp.incident_id
                        and aud_in.creation_date between p_from_date
                                                     and p_to_date
                        and nvl(aud_in.old_incident_resolved_date,l_dt) <>
                                                   nvl(aud_in.incident_resolved_date,l_dt)
                        and aud_in.incident_resolved_date is not null
                        -- above cond is needed to make sure that sr is
                        -- responded. if this cond is not there then incident_resolved_date
                        -- as null to may get selected which is clearly not
                        -- responded condition.
                   )
           and curr_resp.incident_id = aud.incident_id
           -- This make sure that earlier resp to current response is selected
         -- above query will insure that selected response is the last response
           and to_dttm.incident_id        = aud.incident_id
           and to_dttm.creation_date     <= aud.creation_date
           and to_dttm.old_incident_status_id = to_stat.incident_status_id
           and (to_dttm.incident_audit_id = aud.incident_audit_id or
                ((nvl(to_dttm.old_incident_owner_id,-1) <>
                                           nvl(to_dttm.incident_owner_id,-1) or
                nvl(to_dttm.old_incident_status_id,-1) <>
                                           nvl(to_dttm.incident_status_id,-1) and
                to_dttm.creation_date >= to_dttm.incident_date))
               )
           -- above will insure that to_dttm start from responded audit rec
           and to_dttm.incident_id = from_dttm.incident_id
           /*
           and (nvl(from_dttm.old_incident_owner_id,-1) <>
                                           nvl(from_dttm.incident_owner_id,-1)
           or  nvl(from_dttm.old_incident_status_id,-1) <>
                                           nvl(from_dttm.incident_status_id,-1))
           */
           and from_dttm.incident_audit_id =
                   (select max(incident_audit_id) from cs_incidents_audit_b x
                     where x.incident_id = aud.incident_id
                       and ((nvl(x.old_incident_owner_id,-1) <>
                                       nvl(x.incident_owner_id,-1) or
                            nvl(x.old_incident_status_id,-1) <>
                                       nvl(x.incident_status_id,-1)) and
                            x.creation_date >= x.incident_date
                           )
                       and x.creation_date < to_dttm.creation_date
                   )
         group by aud.incident_owner_id,
                  aud.group_id,
                  aud.incident_severity_id,
                  trunc(aud.incident_resolved_date)
        ;
    l_owner_id       cs_incidents_all_b.incident_owner_id    % type;
    l_sev_id         cs_incidents_all_b.incident_severity_id % type;
    l_group_id       cs_incidents_all_b.owner_group_id       % type;
    l_summ_dt        cs_incidents_all_b.close_date           % type;
    l_resl_time      number;
    l_no_of_resp     number;
    l_wait_on_support  number;
    l_wait_on_customer number;
    l_wait_on_int_org  number;
    l_wait_on_ext_org  number;
    l_wait_on_agent    number;
    l_sla_missed       number;
begin
  l_dt := trunc(sysdate) - 10000;
  open c_resl_times;
  loop
    fetch c_resl_times into l_owner_id, l_sev_id, l_group_id,
                           l_summ_dt, l_resl_time, /*l_no_of_resp, */
                           l_wait_on_support, l_wait_on_customer,
                           l_wait_on_int_org, l_wait_on_ext_org,
                           l_wait_on_agent;
    if (c_resl_times%notfound) then exit; end if;
    upload_resp_and_resl(p_incident_owner_id    =>l_owner_id,
                         p_owner_group_id       => l_group_id,
                         p_incident_severity_id => l_Sev_id,
                         p_summary_date         => l_summ_dt,
                         p_owner_type           => 'A',
 p_response_time           => 0,
 p_requests_responded      => 0,
 p_wait_on_agent_resp      => 0,
 p_wait_on_others_resp     => 0,
 p_requests_resolved       => 0,
 p_resp_sla_missed         => 0,
 p_resl_sla_missed         => 0,
 p_beginning_backlog       => null,
 p_ending_backlog          => null,
 p_sr_assigned             => 0,
 p_sr_reassigned_to_others => 0,
                         p_resolve_time          => l_resl_time      ,
                         p_wait_on_support_resl  => l_wait_on_support,
                         p_wait_on_customer_resl => l_wait_on_customer,
                         p_wait_on_int_org_resl  => l_wait_on_int_org,
                         p_wait_on_ext_org_resl  => l_wait_on_ext_org,
                         p_wait_on_agent_resl    => l_wait_on_agent);
  end loop;
  close c_resl_times;
  debug('After Sr Resolution Time:'||to_char(sysdate,'hh24:mi:ss'));
  --
  -- Now reverse the response time if an incident was responded earlier
  open c_resl_times_rev;
  loop
    fetch c_resl_times_rev into l_owner_id, l_sev_id, l_group_id,
                           l_summ_dt, l_resl_time, /*l_no_of_resp, */
                           l_wait_on_support, l_wait_on_customer,
                           l_wait_on_int_org, l_wait_on_ext_org,
                           l_wait_on_agent;
    if (c_resl_times_rev%notfound) then exit; end if;
    upload_resp_and_resl(p_incident_owner_id    => l_owner_id,
                         p_owner_group_id       => l_group_id,
                         p_incident_severity_id => l_Sev_id,
                         p_summary_date         => l_summ_dt,
                         p_owner_type           => 'A',
 p_response_time           => 0,
 p_requests_responded      => 0,
 p_wait_on_agent_resp      => 0,
 p_wait_on_others_resp     => 0,
 p_requests_resolved       => 0,
 p_resp_sla_missed         => 0,
 p_resl_sla_missed         => 0,
 p_beginning_backlog       => null,
 p_ending_backlog          => null,
 p_sr_assigned             => 0,
 p_sr_reassigned_to_others => 0,
                         p_resolve_time          => l_resl_time        *-1,
                         p_wait_on_support_resl  => l_wait_on_support  *-1,
                         p_wait_on_customer_resl => l_wait_on_customer *-1,
                         p_wait_on_int_org_resl  => l_wait_on_int_org  *-1,
                         p_wait_on_ext_org_resl  => l_wait_on_ext_org  *-1,
                         p_wait_on_agent_resl    => l_wait_on_agent    *-1);
  end loop;
  close c_resl_times_rev;
  debug('After Sr Resolution Time Reversal:'||to_char(sysdate,'hh24:mi:ss'));
  --
  -- Get number of requests responded
  --
  open c_resolutions;
  loop
    fetch c_resolutions into l_owner_id, l_sev_id, l_group_id,
                           l_summ_dt,  /*l_resl_time, 17-dec-03*/ l_no_of_resp, l_sla_missed;
    if (c_resolutions%notfound) then exit; end if;
    upload_resp_and_resl(p_incident_owner_id    =>l_owner_id,
                         p_owner_group_id       => l_group_id,
                         p_incident_severity_id => l_Sev_id,
                         p_summary_date         => l_summ_dt,
                         p_owner_type           => 'A',
 p_response_time           => 0,
 p_requests_responded      => 0,
 p_wait_on_agent_resp      => 0,
 p_wait_on_others_resp     => 0,
 p_resolve_time            => 0,
 p_wait_on_agent_resl      => 0,
 p_wait_on_int_org_resl    => 0,
 p_wait_on_ext_org_resl    => 0,
 p_wait_on_support_resl    => 0,
 p_wait_on_customer_resl   => 0,
 p_resp_sla_missed         => 0,
 p_beginning_backlog       => null,
 p_ending_backlog          => null,
 p_sr_assigned             => 0,
 p_sr_reassigned_to_others => 0,
                         p_requests_resolved    => l_no_of_resp,
                         p_resl_sla_missed      => l_sla_missed);
  end loop;
  close c_resolutions;
  debug('After Sr Resolution count:'||to_char(sysdate,'hh24:mi:ss'));
  --
  -- Get number of requests responded to be reversed
  --
  open c_resolutions_rev;
  loop
    fetch c_resolutions_rev into l_owner_id, l_sev_id, l_group_id,
                           l_summ_dt, /*l_resl_time, 17-dec-03*/ l_no_of_resp,l_sla_missed;
    if (c_resolutions_rev%notfound) then exit; end if;
    upload_resp_and_resl(p_incident_owner_id    =>l_owner_id,
                         p_owner_group_id       => l_group_id,
                         p_incident_severity_id => l_Sev_id,
                         p_summary_date         => l_summ_dt,
                         p_owner_type           => 'A',
 p_response_time           => 0,
 p_requests_responded      => 0,
 p_wait_on_agent_resp      => 0,
 p_wait_on_others_resp     => 0,
 p_resolve_time            => 0,
 p_wait_on_agent_resl      => 0,
 p_wait_on_int_org_resl    => 0,
 p_wait_on_ext_org_resl    => 0,
 p_wait_on_support_resl    => 0,
 p_wait_on_customer_resl   => 0,
 p_resp_sla_missed         => 0,
 p_beginning_backlog       => null,
 p_ending_backlog          => null,
 p_sr_assigned             => 0,
 p_sr_reassigned_to_others => 0,
                         p_requests_resolved    => l_no_of_resp*-1,
                         p_resl_sla_missed      => l_sla_missed*-1);
  end loop;
  close c_resolutions_rev;
  debug('After Sr Resolution count Reversal:'||to_char(sysdate,'hh24:mi:ss'));
  --
  exception
   when others then
     fnd_file.put_line(fnd_file.log,'Error:'||sqlerrm);
     raise fnd_api.g_exc_unexpected_error;
end get_resolution_timings;
procedure upload_first_resolutions(p_sql varchar2,
                                   p_owner_type varchar2,
                                   p_from_date date,
                                   p_to_date   date,
                                   p_upload_type varchar2
                                   ) as
 Type Resolution_cursor_type is ref cursor;
 c_first_resolutions Resolution_cursor_type;
 l_dt date ;
 l_owner_id     cs_incidents_all_b.incident_owner_id    % type;
 l_sev_id       cs_incidents_all_b.incident_severity_id % type;
 l_resol_dt     cs_incidents_all_b.incident_date        % type;
 l_inv_item_id  cs_incidents_all_b.inventory_item_id    % type;
 l_inv_org_id   cs_incidents_all_b.inv_organization_id  % type;
 l_prob_code    cs_incidents_all_b.problem_code         % type;
 l_resol_code   cs_incidents_all_b.resolution_code      % type;
 l_sr_resolved  number;
 l_sr_reopen    number;
 l_sr_reopen2   number;
begin
 l_dt := trunc(sysdate) +3000;
 if p_upload_type = 'RESL' then
    open c_first_resolutions for p_sql using l_dt, l_dt,p_from_date, p_to_date,
                               l_dt, l_dt;
 elsif P_UPLOAD_TYPE = 'REOPEN' then
    open c_first_resolutions for p_sql using p_from_date, p_to_date,
                                             p_from_date, p_to_date;
 elsif P_UPLOAD_TYPE = 'REVERSE' then
    open c_first_resolutions for p_sql using p_from_date, p_to_date,
                                             p_from_date, p_to_date,
                                             p_from_date, p_from_date;
 else
    raise_application_error(-20001,'Invalid Load type');
 end if;
 loop
   fetch c_first_resolutions into l_owner_id,
                           l_sev_id,
                           l_resol_dt,
                           l_inv_item_id,
                           l_inv_org_id,
                           l_prob_code,
                           l_resol_code,
                           l_sr_resolved,
                           l_sr_reopen,
                           l_sr_reopen2;
   if c_first_resolutions%notfound then exit; end if;
   update csy_resolution_qlty
      set total_sr_resolved_1st_time = nvl(total_sr_resolved_1st_time,0) +
                                           l_sr_resolved,
          total_sr_reopened = nvl(total_sr_reopened,0)+l_sr_reopen,
          tot_sr_reopened_once_or_more = nvl(tot_sr_reopened_once_or_more,0)+
                                          l_sr_reopen2
    where summary_date         = l_resol_dt
      and incident_owner_id    = l_owner_id
      and owner_type           = p_owner_type
      and incident_severity_id = l_sev_id
      and inv_organization_id  = l_inv_org_id
      and inventory_item_id    = l_inv_item_id
      and resolution_code      = l_resol_code
      and problem_code         = l_prob_code;
    if (sql%notfound ) then
       insert into csy_resolution_qlty (
               SUMMARY_DATE                   ,
               INCIDENT_OWNER_ID              ,
               OWNER_TYPE                     ,
               INCIDENT_SEVERITY_ID           ,
               INV_ORGANIZATION_ID            ,
               INVENTORY_ITEM_ID              ,
               RESOLUTION_CODE                ,
               PROBLEM_CODE                   ,
               TOTAL_SR_RESOLVED_1ST_TIME     ,
               TOTAL_SR_REOPENED              ,
               TOT_SR_REOPENED_ONCE_OR_MORE   ,
               last_update_date              ,
               last_updated_by               ,
               creation_date                 ,
               created_by                    ,
               last_update_login             ,
               program_id                    ,
               program_login_id              ,
               program_application_id        ,
               request_id                    )
       values (l_resol_dt    ,
               l_owner_id    ,
               p_owner_type  ,
               l_sev_id      ,
               l_inv_org_id  ,
               l_inv_item_id ,
               l_resol_code  ,
               l_prob_code   ,
               l_sr_resolved ,
               l_sr_reopen   ,
               l_sr_reopen2  ,
               sysdate                       ,
               g_user_id                     ,
               sysdate                       ,
               g_user_id                     ,
               g_login_user_id               ,
               g_conc_program_id             ,
               g_conc_login_id               ,
               g_conc_appl_id                ,
               g_conc_request_id
              );
    end if;
 end loop;
 close c_first_resolutions;
 exception
   when others then
     fnd_file.put_line(fnd_file.log,'Error:'||sqlerrm);
     raise fnd_api.g_exc_unexpected_error;
end;
procedure get_sr_resolutions      (p_from_date in date,
                                   p_to_date   in date) is
 --cursor c_agent_resolutions is
 l_sql varchar2(4000) ;
begin
 l_sql := '
 select first_rslvd.incident_owner_id                                ,
        nvl(first_rslvd.incident_severity_id,-1) incident_severity_id,
        trunc(first_rslvd.incident_resolved_date)            summary_date        ,
        nvl(first_rslvd.inventory_item_id  , -1 )         inventory_item_id   ,
        nvl(first_rslvd.inv_organization_id, -1 )         inv_organization_id ,
        -- once prob and resol code are added to audit table,
        -- change the source of these columns and remove sr table from
        -- from clause
        nvl(first_rslvd.problem_code       ,''-1'')         problem_code        ,
        nvl(first_rslvd.resolution_code    ,''-1'')         resolution_code     ,
        count(first_rslvd.incident_id)           sr_resolved           ,
        0 sr_reopened,
        0 sr_reopened2
   from cs_incidents_audit_b first_rslvd,
        cs_incidents_all_b sr
  where sr.incident_id = first_rslvd.incident_id
    and first_rslvd.incident_owner_id is not null
    -- so that only those rec are selected where resolution date is
    -- set from null to NOT NULL
    and nvl(first_rslvd.incident_resolved_date, :l_dt) <>
                              nvl(first_rslvd.old_incident_resolved_date,:l_dt)
    and first_rslvd.incident_resolved_date is not null
    -- select only resloutions in a given period
    and first_rslvd.creation_date between :p_from_date and :p_to_date
    -- select a resolution only if it first time resolution
    and not exists  (select 1 from cs_incidents_audit_b x
                      where x.incident_resolved_date is not null
                        and nvl(x.incident_resolved_date, :l_dt) <>
                               nvl(x.old_incident_resolved_date, :l_dt)
                        and x.incident_id = first_rslvd.incident_id
                        and x.incident_owner_id = first_rslvd.incident_owner_id
                        and x.creation_date < first_rslvd.creation_date
                   )
             -- this will give first resolution information in a given period
  group by first_rslvd.incident_owner_id,
           first_rslvd.incident_severity_id,
           first_rslvd.inventory_item_id,
           first_rslvd.inv_organization_id,
           first_rslvd.problem_code,
           first_rslvd.resolution_code,
           trunc(first_rslvd.incident_resolved_date)' ;
  debug(l_sql);
  debug('before call to upload_first_resolution');
  upload_first_resolutions(l_sql,'A',p_from_date, p_to_date,'RESL');
 -- group quality
  l_sql := replace(l_sql,'incident_owner_id','group_id');
  debug('before call to upload_first_resolution for group');
  upload_first_resolutions(l_sql,'G',p_from_date, p_to_date,'RESL');
 -- Reopen and reopen for second or subsequent times
 l_sql := '
 select incident_owner_id,
        incident_severity_id,
        summary_date,
        inventory_item_id,
        inv_organization_id,
        problem_code,
        resolution_code,
        0 sr_resolved,
        sum(rework) rework,
        sum(rework2) rework2 from (
 select last_unrslvd.incident_owner_id incident_owner_id,
        nvl(last_unrslvd.incident_severity_id,-1) incident_severity_id,
        trunc(last_unrslvd.creation_date)         summary_date,
        last_unrslvd.incident_id                  incident_id,
        nvl(sr.inventory_item_id,-1)              inventory_item_id,
        nvl(sr.inv_organization_id,-1)            inv_organization_id,
        nvl(last_unrslvd.problem_code,''-1'')               problem_code,
        nvl(last_unrslvd.resolution_code,''-1'')            resolution_code,
        decode(count(last_unrslvd.old_incident_resolved_date),0,0,1) rework,
   /* if there are any old close dates, rewrk will be one. so for
      first reopen or second reopen
      it will always return 1*/
        decode(count(prev_unrsltns.old_incident_resolved_date),0,0,  1) rework2
   /* 1 mean there are atleast two reopen, 1 for last_unrslvd and
      1 from prev_unrsltns
      it will return 1 only if there are atleast 2 old close dates */
  from cs_incidents_audit_b last_unrslvd,
    cs_incidents_audit_b    prev_unrsltns,
    cs_incidents_all_b      sr
 where sr.incident_id = last_unrslvd.incident_id
   and last_unrslvd.incident_owner_id is not null
   and last_unrslvd.old_incident_resolved_date is not null
   and last_unrslvd.incident_resolved_date is null
   /* select only last reopen in a given period */
   and last_unrslvd.creation_date between :p_from_date and :p_to_date
   and last_unrslvd.incident_audit_id =
        (select max(incident_audit_id) from cs_incidents_audit_b x
          where x.old_incident_resolved_date         is not null
            and x.incident_resolved_date             is     null
            and x.incident_id            = last_unrslvd.incident_id
            and x.incident_owner_id      = last_unrslvd.incident_owner_id
            and x.creation_date between  :p_from_date and :p_to_date
        ) /* this will give last reopen information in a given period*/
   and prev_unrsltns.incident_id       (+)   = last_unrslvd.incident_id
   and prev_unrsltns.creation_date     (+) < last_unrslvd.creation_date
   and prev_unrsltns.incident_owner_id (+) = last_unrslvd.incident_owner_id
   and prev_unrsltns.incident_resolved_date        (+) is null
   and prev_unrsltns.old_incident_resolved_date    (+) is not null
  /* above 5 lines join with audit table where same SR was set from
     resolved to unresolved*/
 group by last_unrslvd.incident_owner_id,
          last_unrslvd.incident_id,
          last_unrslvd.incident_severity_id,
          sr.inventory_item_id,
          sr.inv_organization_id,
          last_unrslvd.problem_code,
          last_unrslvd.resolution_code,
          trunc(last_unrslvd.creation_date))
 group by incident_owner_id,
        incident_severity_id,
        summary_date,
        inventory_item_id,
        inv_organization_id,
        problem_code,
        resolution_code';
  upload_first_resolutions(l_sql,'A',p_from_date, p_to_date, 'REOPEN');
  debug(l_sql);
  l_sql := replace(l_sql,'incident_owner_id','group_id');
  upload_first_resolutions(l_sql,'G',p_from_date, p_to_date, 'REOPEN');
  debug(l_sql);
  -- reversal of reopen and reopen for second or subsequent times
  l_sql := '
 select incident_owner_id,
        incident_severity_id,
        summary_date,
        inventory_item_id,
        inv_organization_id,
        problem_code,
        resolution_code,
        0 sr_resolved,
        -1 * sum(rework) rework,
        -1 * sum(reopen) reopen from (
 select prev_unrsltns.incident_owner_id,
        prev_unrsltns.incident_id,
        prev_unrsltns.incident_severity_id,
        trunc(prev_unrsltns.creation_date) summary_date,
        nvl(prev_unrsltns.inventory_item_id,-1) inventory_item_id,
        nvl(prev_unrsltns.inv_organization_id,-1) inv_organization_id,
        nvl(prev_unrsltns.problem_code,''-1'') problem_code,
        nvl(prev_unrsltns.resolution_code,''-1'') resolution_code,
        decode(count(prev_unrsltns.old_incident_resolved_date),0,0,1) rework,
      /* 1 */
        decode(count(prev_unrsltns1.old_incident_resolved_date),0,0, 1)reopen
      /** it will return 1 only if there are atleast 2 old close dates */
  from cs_incidents_audit_b curr_unrslvd,
       cs_incidents_audit_b prev_unrsltns,
           /* this indicates if a sr is reworked*/
       cs_incidents_audit_b prev_unrsltns1,
                 /* this table indicates if a sr is reworked more than once*/
       cs_incidents_all_b sr
 where sr.incident_id = prev_unrsltns.incident_id
   and curr_unrslvd.incident_owner_id is not null
   and curr_unrslvd.old_incident_resolved_date is not null
   and curr_unrslvd.incident_resolved_date     is     null
   /* select only rework in a given period */
   and curr_unrslvd.creation_date between :p_from_date and :p_to_date
   and curr_unrslvd.incident_audit_id =
         (select max(incident_audit_id) from cs_incidents_audit_b x
           where x.old_incident_resolved_date is not null
             and x.incident_resolved_date     is null
             and x.incident_id = curr_unrslvd.incident_id
             and x.incident_owner_id = curr_unrslvd.incident_owner_id
             and x.creation_date between :p_from_date and :p_to_date
          ) /* this will give last unresolution information
                     in a given period */
   /* 2 */
   and prev_unrsltns.incident_id               = curr_unrslvd.incident_id
   and prev_unrsltns.creation_date           < :p_from_date
   /* here we need to look for unresolutions before concurrent program run.*/
   and prev_unrsltns.incident_resolved_date         is null
   and prev_unrsltns.old_incident_resolved_date     is not null
   and prev_unrsltns.incident_owner_id  = curr_unrslvd.incident_owner_id
   and prev_unrsltns.incident_audit_id =
          (select max(y.incident_audit_id) from cs_incidents_audit_b y
            where y.incident_id = prev_unrsltns.incident_id
              and y.incident_owner_id = prev_unrsltns.incident_owner_id
              and y.creation_date < :p_from_date
              and y.incident_resolved_date is null
              and y.old_incident_resolved_date is not null
          )
   and prev_unrsltns1.incident_id                (+) = prev_unrsltns.incident_id
   and prev_unrsltns1.creation_date              (+) < prev_unrsltns.creation_date
   and prev_unrsltns1.incident_resolved_date     (+) is null
   and prev_unrsltns1.old_incident_resolved_date (+) is not null
   and prev_unrsltns1.incident_owner_id          (+) = prev_unrsltns.incident_owner_id
 group by prev_unrsltns.incident_owner_id,
       prev_unrsltns.incident_id,
       prev_unrsltns.incident_severity_id,
       trunc(prev_unrsltns.creation_date),
       prev_unrsltns.inventory_item_id,
       prev_unrsltns.inv_organization_id,
       prev_unrsltns.problem_code,
       prev_unrsltns.resolution_code)
 group by incident_owner_id,
        incident_severity_id,
        summary_date,
        inventory_item_id,
        inv_organization_id,
        problem_code,
        resolution_code';
      /* 1
      if there are any close dates, rewrk will be one. so for any reopen
      it will always return 1
      **/
   /* 2
   -- No need for outer join here like in previous query.
      in previous qry, we are not sure if
   -- there is any previous reopen. Here we are sure that count need
      to be subtracted
   -- only if previous reopens exists
   */
  debug('before call to upload_first_resolution reverse for Agent');
  debug(l_sql);
  upload_first_resolutions(l_sql,'A',p_from_date, p_to_date, 'REVERSE');
  -- Update for Group
  l_sql := replace(l_sql,'incident_owner_id','group_id');
  debug('before call to upload_first_resolution reverse for Group');
  debug(l_sql);
  upload_first_resolutions(l_sql,'G',p_from_date, p_to_date, 'REVERSE');
---
---
 exception
   when others then
     fnd_file.put_line(fnd_file.log,'Error:'||sqlerrm);
     raise fnd_api.g_exc_unexpected_error;
end;
procedure upload_assignments(p_sql varchar2,
                             p_load_type varchar2,
                             p_owner_type varchar2,
                             p_from_date date,
                             p_to_date   date
                             ) as
 l_dt date;
 l_owner_id jtf_rs_resource_extns.resource_id % type;
 l_group_id jtf_rs_groups_b.group_id % type;
 l_sev_id   cs_incident_severities_b.incident_severity_id % type;
 l_sr_in    number;
 l_sr_out   number;
 Type AssignmentCursorType is ref cursor;
 c_agent_assignment AssignmentCursorType;
 l_incident_owner_id cs_incidents_all_b.incident_owner_id % type;
 l_owner_group_id    cs_incidents_all_b.owner_group_id    % type;
begin
 if (p_load_type = 'ADD' ) then
    open c_agent_assignment for p_sql using
             p_from_date, p_to_date,
             p_from_date, p_to_date,
             p_from_date, p_to_date,
             p_from_date, p_to_date;
 else
    open c_agent_assignment for p_sql using
             p_from_date, p_to_date,
             p_from_date, p_to_date,
             p_from_date, p_from_date,
             --p_from_date, p_to_date,
             --p_from_date, p_to_date,
             --p_from_date, p_from_date,
             p_from_date, p_to_date,
             p_from_date, p_to_date,
             p_from_date, p_from_date;
 end if;
 l_incident_owner_id := -1;
 l_owner_group_id    := -1;
 loop
    fetch c_agent_assignment into l_dt, l_owner_id,  l_sev_id,
                                  l_sr_in, l_sr_out;
    if c_agent_assignment%notfound then exit; end if;
    if (p_owner_type = 'A') then
       l_incident_owner_id := l_owner_id;
    else
       l_owner_group_id    := l_owner_id;
    end if;
    update csy_response_resolutions
       set total_sr_assigned = nvl(total_sr_assigned,0)+l_sr_in,
           total_sr_reassigned_to_others = nvl(total_sr_reassigned_to_others,0)+
                                            l_sr_out
     where summary_date = l_dt
       and incident_owner_id    = l_incident_owner_id
       and owner_group_id       = l_owner_group_id
       and owner_type           = p_owner_type
       and incident_severity_id = l_sev_id;
    if (sql%notfound) then
       insert into csy_response_resolutions
              (summary_date,
               incident_owner_id,
               incident_severity_id,
               total_sr_assigned,
               total_sr_reassigned_to_others,
               owner_group_id,
               owner_type,
               last_update_date              ,
               last_updated_by               ,
               creation_date                 ,
               created_by                    ,
               last_update_login             ,
               program_id                    ,
               program_login_id              ,
               program_application_id        ,
               request_id                    )
       values (l_dt,
               l_incident_owner_id,
               l_sev_id,
               l_sr_in,
               l_sr_out,
               l_owner_group_id,
               p_owner_type,
               sysdate                       ,
               g_user_id                     ,
               sysdate                       ,
               g_user_id                     ,
               g_login_user_id               ,
               g_conc_program_id             ,
               g_conc_login_id               ,
               g_conc_appl_id                ,
               g_conc_request_id  );
    end if;
 end loop;
 close c_agent_assignment;
end;
procedure get_sr_agent_assignments(p_from_date in date,
                                   p_to_date   in date) is
 --cursor c_agent_assignment is
  l_sql   varchar2(8000);
  l_sql_in_sel        varchar2(1000);
  l_sql_out_sel        varchar2(1000);
  l_sql_in_sel_r        varchar2(1000);
  l_sql_out_sel_r        varchar2(1000);
  l_sql_in_whr        varchar2(2000);
  l_sql_out_whr        varchar2(2000);
  l_sql_in_group_by   varchar2(1000);
  l_sql_out_group_by   varchar2(1000);
  l_sql_sr_in_rev  varchar2(4000);
  l_sql_sr_out_rev varchar2(4000);
  l_sql_sr_out_rev1 varchar2(4000);
  l_temp varchar2(4000);
begin
 l_sql_in_sel := '
 select trunc(aud.creation_date)        summary_date,
        aud.incident_owner_id           incident_owner_id,
        nvl(incident_severity_id,-1)    incident_severity_id,
        aud.incident_id                 incident_id_in,
        to_number(null)                 incident_id_out';
 l_sql_in_sel_r := '
    select aud.incident_id,
           aud.incident_owner_id';
 l_sql_in_whr := '
   from cs_incidents_audit_b aud
  where /*nvl(aud.incident_owner_id,-1) <> nvl(aud.old_incident_owner_id,-1)
    and aud.incident_owner_id is not null
    and */ aud.creation_date between :p_from_date and :p_to_date
    -- same condition are present in subquery too. it existance of these conditions outside the
    -- subquery is meaningless. remove it when modifying this query.
    and aud.incident_audit_id =
                (select max(incident_audit_id)
                   from cs_incidents_audit_b aud_in
                  where aud_in.incident_id = aud.incident_id
                    and aud_in.creation_date between :p_from_date
                                                 and :p_to_date
                    and aud_in.incident_owner_id = aud.incident_owner_id
                    -- above con will take care of aud_in.incident_woner_id
                    -- is not null
                    and aud_in.incident_owner_id is not null
                    and (nvl(aud_in.incident_owner_id,-1) <>
                                     nvl(aud_in.old_incident_owner_id,-1) or
                         aud_in.incident_severity_id <> nvl(aud_in.old_incident_severity_id,-1)
                        )
                )';
/*
  l_sql_in_group_by := '
  group by trunc(aud.creation_date),
           aud.incident_owner_id,
           nvl(aud.group_id,-1),
           incident_severity_id';
****/
 l_sql_out_sel := '
 select trunc(aud.creation_date)     summary_date,
        aud.old_incident_owner_id    incident_owner_id,
        nvl(incident_severity_id,-1) incident_severity_id,
        to_number(null)              incident_id_in,
        aud.incident_id              incident_id_out';
 l_sql_out_sel_r := '
    select aud.incident_id,
           aud.old_incident_owner_id';
 l_sql_out_whr := '
   from cs_incidents_audit_b aud
  where nvl(aud.incident_owner_id,-1) <> nvl(aud.old_incident_owner_id,-1)
    and aud.old_incident_owner_id is not null
    and aud.creation_date between :p_from_date and :p_to_date
    and aud.incident_audit_id =
               (select max(incident_audit_id)
                  from cs_incidents_audit_b aud_in
                 where aud_in.incident_id = aud.incident_id
                   and aud_in.creation_date between :p_from_date and :p_to_date
                   and (aud_in.old_incident_owner_id =aud.old_incident_owner_id  or
                        aud_in.incident_owner_id =aud.old_incident_owner_id )
                   and nvl(aud_in.incident_owner_id,-1) <>
                                     nvl(aud_in.old_incident_owner_id,-1)
                )';
 /* in above statement comparaing aud.old_incident_owner_id ot new and old owner is required
    suppose a sr is assigned to A1 and then to A2 and then back to A1. if we do not use new and
    old owners, then audit record represent change to A2 will get selected and it will give 1
    reassigned to others for A1. comparing old and new both will prevent it.
    1/8/2004 smisra
  */
  /*
  l_sql_out_group_by := '
  group by trunc(aud.creation_date),
           aud.old_incident_owner_id,
           nvl(aud.old_group_id,-1),
           incident_severity_id';
  */
 l_sql := 'select summary_date,
                  incident_owner_id,
                  incident_severity_id,
                  count(distinct incident_id_in) sr_in,
                  count(distinct incident_id_out) sr_out
           from ( ' ||l_sql_in_sel || l_sql_in_whr || ' union ' ||
          l_sql_out_sel || l_sql_out_whr || ')
         group by summary_date, incident_owner_id,
                  incident_severity_id' ;
 debug(l_sql);
 upload_assignments(l_sql,
                    'ADD', 'A', p_from_date, p_to_date);
 l_sql := replace(l_sql,'incident_owner_id', 'group_id');
 debug(l_sql);
 upload_assignments(l_sql,
                    'ADD', 'G', p_from_date, p_to_date);
 l_sql_sr_in_rev := '
   select trunc(prev_asgn.creation_date) summary_date,
          prev_asgn.incident_owner_id    incident_owner_id,
          nvl(incident_severity_id,-1)   incident_severity_id,
          prev_asgn.incident_id          incident_id_in,
          to_number(null)                incident_id_out
     from cs_incidents_audit_b prev_asgn, ( ' || l_sql_in_sel_r ||
          l_sql_in_whr ||'
    ) cur_asgn
  where cur_asgn.incident_id = prev_asgn.incident_id
    and cur_asgn.incident_owner_id = prev_asgn.incident_owner_id
    and nvl(prev_asgn.incident_owner_id,-1) <>
                       nvl(prev_asgn.old_incident_owner_id,-1)
    and prev_asgn.incident_owner_id is not null
    and prev_asgn.creation_date < :p_from_date
    and prev_asgn.incident_audit_id =
         (select max(incident_audit_id)
            from cs_incidents_audit_b aud_in
           where aud_in.incident_id = prev_asgn.incident_id
             and aud_in.incident_owner_id = prev_asgn.incident_owner_id
             and (nvl(aud_in.incident_owner_id,-1) <>
                       nvl(aud_in.old_incident_owner_id,-1) or
                  aud_in.incident_severity_id <> nvl(aud_in.old_incident_Severity_id,-1)
                 )
             and aud_in.incident_owner_id is not null
             and aud_in.creation_date < :p_from_date
         )';
 /**** this one is not used anymore
 l_sql_sr_out_rev := '
   select trunc(prev_asgn.creation_date)   summary_date,
          prev_asgn.old_incident_owner_id  incident_owner_id,
          nvl(incident_severity_id,-1)     incident_severity_id,
          null                             incident_id_in,
          prev_asgn.incident_id            incident_id_out
     from cs_incidents_audit_b prev_asgn, ( ' || l_sql_out_sel_r ||
               l_sql_out_whr || '
    ) cur_asgn
  where cur_asgn.incident_id = prev_asgn.incident_id
    and cur_asgn.old_incident_owner_id = prev_asgn.old_incident_owner_id
    and nvl(prev_asgn.incident_owner_id,-1) <>
                       nvl(prev_asgn.old_incident_owner_id,-1)
    and prev_asgn.old_incident_owner_id is not null
    and prev_asgn.creation_date < :p_from_date
    and prev_asgn.incident_audit_id =
         (select max(incident_audit_id)
            from cs_incidents_audit_b aud_in
           where aud_in.incident_id = prev_asgn.incident_id
             and aud_in.old_incident_owner_id = prev_asgn.old_incident_owner_id
             and nvl(prev_asgn.incident_owner_id,-1) <>
                       nvl(prev_asgn.old_incident_owner_id,-1)
             and prev_asgn.old_incident_owner_id is not null
             and aud_in.creation_date < :p_from_date
         )';
 ***** 3/5/04 smisra ********************************************/
 /* 10/17/2003
    This query will reverse any out assignments when a service request
    is assigned back to same agent. For example Agent A1 was assgined
    an SR on 10/1/03, on 10/4/03, same SR wasd assigned to Agent A2
    on 10/17/03, SR comes back to Agent A1. in that case there is need for
    two reversals, one for 10/1/03 correcting SR IN and one for 10/4/03
    correcting SR OUT. So on 10/17, for Agent A1, SR IN will be one and
    SR OUT will be zero.
 */
 l_sql_sr_out_rev1 := '
   select trunc(prev_asgn.creation_date)   summary_date,
          prev_asgn.old_incident_owner_id  incident_owner_id,
          nvl(incident_severity_id,-1)     incident_severity_id,
          to_number(null)                  incident_id_in,
          prev_asgn.incident_id            incident_id_out
     from cs_incidents_audit_b prev_asgn, ( ' || l_sql_in_sel_r ||
               l_sql_in_whr || '
    ) cur_asgn
  where cur_asgn.incident_id = prev_asgn.incident_id
    and cur_asgn.incident_owner_id = prev_asgn.old_incident_owner_id
    and nvl(prev_asgn.incident_owner_id,-1) <>
                       nvl(prev_asgn.old_incident_owner_id,-1)
    and prev_asgn.old_incident_owner_id is not null
    and prev_asgn.creation_date < :p_from_date
    and prev_asgn.incident_audit_id =
         (select max(incident_audit_id)
            from cs_incidents_audit_b aud_in
           where aud_in.incident_id = prev_asgn.incident_id
             and aud_in.old_incident_owner_id = prev_asgn.old_incident_owner_id
             and nvl(aud_in.incident_owner_id,-1) <>
                       nvl(aud_in.old_incident_owner_id,-1)
             and aud_in.old_incident_owner_id is not null
             and aud_in.creation_date < :p_from_date
         )';
 /* in this statement l_sql_sr_out_rev is commented out. reason whenever, SR is assigned to
    an agent, SR OUT are reveresed at that time. so no need to do it again
    1/8/2004 smisra
  */
 l_sql := ' select summary_date,
                   incident_owner_id,
                   incident_severity_id,
                   count(distinct incident_id_in)  * -1 sr_in,
                   count(distinct incident_id_out) * -1 sr_our
              from ( ' || l_sql_sr_in_rev || ' union ' ||
                     /*  l_sql_sr_out_rev || ' union ' ||*/
                       l_sql_sr_out_rev1 || ')
             group by summary_date,
                      incident_owner_id,
                      incident_severity_id';
 debug(l_sql);
 upload_assignments(l_sql,
                    'REV', 'A', p_from_date, p_to_date);

 l_sql := replace(l_sql,'incident_owner_id', 'group_id');
 debug(l_sql);
 upload_assignments(l_sql,
                    'REV', 'G', p_from_date, p_to_date);
 /*
 */
  exception
   when others then
     fnd_file.put_line(fnd_file.log,'Error:'||sqlerrm);
     raise fnd_api.g_exc_unexpected_error;
end;
procedure get_sr_group_assignments(p_from_date in date,
                                   p_to_date   in date) is
begin
 null;
 /* 10/13/2003 Not used
 merge into csy_response_resolutions a using (
 select trunc(aud.creation_date) summary_date,
        aud.group_id             group_id         ,
        incident_severity_id     incident_severity_id,
        count(distinct aud.incident_id) sr_in,
        0 sr_out
   from cs_incidents_audit_b aud
  where nvl(aud.group_id,-1) <> nvl(aud.old_group_id,-1)
    and aud.group_id is not null
    and aud.creation_date between p_from_date and p_to_date
    and aud.incident_audit_id =
                 (select max(incident_audit_id)
                    from cs_incidents_audit_b aud_in
                   where aud_in.incident_id = aud.incident_id
                     and aud_in.creation_date between p_from_date and p_to_date
                     and aud_in.group_id          = aud.group_id
                     and nvl(aud_in.group_id,-1) <> nvl(aud_in.old_group_id,-1)
                     and aud_in.group_id is not null
                 )
  group by trunc(aud.creation_date),
           aud.group_id         ,
           incident_severity_id
 union
 select trunc(aud.creation_date),
        aud.old_group_id         ,
        incident_severity_id,
        0,
        count(distinct aud.incident_id) sr_agent_out
   from cs_incidents_audit_b aud
  where nvl(aud.group_id,-1) <> nvl(aud.old_group_id,-1)
    and aud.old_group_id is not null
    and aud.creation_date between p_from_date and p_to_date
    and aud.incident_audit_id =
                (select max(incident_audit_id)
                   from cs_incidents_audit_b aud_in
                  where aud_in.incident_id = aud.incident_id
                    and aud_in.creation_date between p_from_date and p_to_date
                    and aud_in.old_group_id          =aud.old_group_id
                    and nvl(aud_in.group_id,-1) <> nvl(aud_in.old_group_id,-1)
                    and aud_in.old_group_id is not null
                )
  group by trunc(aud.creation_date),
           aud.old_group_id         ,
           incident_severity_id) b
 on (a.summary_date         = b.summary_date        and
     a.owner_group_id       = b.group_id            and
     a.incident_severity_id = b.incident_Severity_id and
     a.incident_owner_id    = -1 and
     a.owner_type           = 'G')
 when matched then
  update set total_sr_assigned = nvl(a.total_sr_assigned,0) + b.sr_in,
             total_sr_reassigned_to_others
                        = nvl(a.total_sr_reassigned_to_others,0) + b.sr_out
 when not matched then
  insert (summary_date        ,
          owner_group_id      ,
          incident_severity_id,
          total_sr_assigned  ,
          total_sr_reassigned_to_others,
          incident_owner_id,
          owner_type)
  values (b.summary_date,
          b.group_id         ,
          nvl(b.incident_severity_id,-1),
          b.sr_in,
          b.sr_out,
          -1, 'G');
  exception
   when others then
     fnd_file.put_line(fnd_file.log,'Error:'||sqlerrm);
 ***************************************************************************/
end;
procedure get_response_timings(p_from_date in date,
                               p_to_date   in date) as
  l_dt date ;
  l_sql   varchar2(4000);
  l_sla_missed number;
  cursor c_responses is
    select nvl(aud.incident_owner_id,-1)   incident_owner_id,
           nvl (aud.incident_severity_id,-1) incident_severity_id,
           nvl (aud.group_id,-1)             owner_group_id,
           trunc(nvl(aud.inc_responded_by_date,incident_resolved_date)) inc_responded_by_date,
           count(aud.incident_id) responses,
           -- in responded_bydate is greater than obligation date, sla missed
           count(decode(sign(nvl(aud.inc_responded_by_date,aud.incident_resolved_date)-aud.obligation_date),
                        1,1,null)) resp_sla_missed
          from cs_incidents_audit_b aud      --this is audit rec for response
         where aud.incident_audit_id =
                   ( select max(incident_audit_id)
                       from cs_incidents_audit_b aud_in
                      where aud_in.incident_id = aud.incident_id
                        and aud_in.creation_date between p_from_date
                                                     and p_to_date
                        and nvl(nvl(aud_in.old_inc_responded_by_date,aud_in.old_incident_resolved_date),l_dt) <>
                                                   nvl(nvl(aud_in.inc_responded_by_date,aud_in.incident_resolved_date),l_dt)
                        and (aud_in.inc_responded_by_date is not null or
                             aud_in.incident_resolved_date is not null)
                        -- above cond is needed to make sure that sr is
                        -- responded. if this cond is not there then inc_responded_by_date
                        -- as null to may get selected which is clearly not
                        -- responded condition.
                   )
         -- above query will insure that selected response is the last response
         group by aud.incident_owner_id,
                  aud.group_id,
                  aud.incident_severity_id,
                  trunc(nvl(aud.inc_responded_by_date,incident_resolved_date));
  cursor c_responses_rev is
    select /*+ ORDERED */
           nvl(prev_resp.incident_owner_id,-1)   incident_owner_id,
           nvl (prev_resp.incident_severity_id,-1) incident_severity_id,
           nvl (prev_resp.group_id,-1)             owner_group_id,
           trunc(nvl(prev_resp.inc_responded_by_date,prev_resp.incident_resolved_date)) inc_responded_by_date,
           --sum(prev_resp.inc_responded_by_date - prev_resp.incident_date) resp_time,
           -- we need to select distinct because each responded
           -- audit will be joined with mulitple from and to aduit record
           count(distinct prev_resp.incident_id) responses,
           -- in responded_bydate is greated than obligation date, sla missed
           count(decode(sign(nvl(prev_resp.inc_responded_by_date,prev_resp.incident_resolved_date)-prev_resp.obligation_date),
                        1,1,null)) resp_sla_missed
          from cs_incidents_audit_b curr_resp,
                    --this is audit rec for response in curr run dates
               cs_incidents_audit_b prev_resp
                    -- this is response in before curr run dates
         where curr_resp.incident_audit_id =
                   ( select max(incident_audit_id)
                       from cs_incidents_audit_b aud_in
                      where aud_in.incident_id = curr_resp.incident_id
                        and aud_in.creation_date between p_from_date
                                                     and p_to_date
                        and nvl(nvl(aud_in.old_inc_responded_by_date,aud_in.old_incident_resolved_date),l_dt) <>
                                                   nvl(nvl(aud_in.inc_responded_by_date,aud_in.incident_resolved_date),l_dt)
                        and (aud_in.inc_responded_by_date is not null or
                             aud_in.incident_resolved_date is not null)
                        -- above cond is needed to make sure that sr is
                        -- responded. if this cond is not there then inc_responded_by_date
                        -- as null to may get selected which is clearly not
                        -- responded condition.
                   )
         -- above query will insure that selected response is the last response
           and prev_resp.incident_id = curr_resp.incident_id
           and prev_resp.incident_audit_id = ( select max(incident_audit_id)
                       from cs_incidents_audit_b aud_in1
                      where aud_in1.incident_id = curr_resp.incident_id
                        and aud_in1.creation_date < p_from_date
                        and nvl(nvl(aud_in1.old_inc_responded_by_date,aud_in1.old_incident_resolved_date),l_dt) <>
                                                   nvl(nvl(aud_in1.inc_responded_by_date,aud_in1.incident_resolved_date),l_dt)
                        and (aud_in1.inc_responded_by_date is not null or
                             aud_in1.incident_resolved_date is not null)
                        -- above cond is needed to make sure that sr is
                        -- responded. if this cond is not there then inc_responded_by_date
                        -- as null to may get selected which is clearly not
                        -- responded condition.
                   )
         group by prev_resp.incident_owner_id,
                  prev_resp.group_id,
                  prev_resp.incident_severity_id,
                  trunc(nvl(prev_resp.inc_responded_by_date,prev_resp.incident_resolved_date));
  cursor c_resp_times is
    select /*+ ORDERED */
           nvl(aud.incident_owner_id,-1)   incident_owner_id,
           nvl (aud.incident_severity_id,-1) incident_severity_id,
           nvl (aud.group_id,-1)             owner_group_id,
           trunc(nvl(aud.inc_responded_by_date,aud.incident_resolved_date)) inc_responded_by_date,
           sum(decode(aud.incident_owner_id,to_dttm.old_incident_owner_id,
                 csy_kpi_pkg.get_agents_time(to_dttm.old_incident_owner_id,
                   decode(from_dttm.old_incident_date,null,from_dttm.incident_date,from_dttm.creation_date),
                   decode(aud.incident_audit_id,to_dttm.incident_audit_id,
                           nvl(aud.inc_responded_by_date,aud.incident_resolved_date),to_dttm.creation_date)),0)
              ) * 1440     resp_time,
           -- we need to select distinct because each responded
           -- audit will be joined with mulitple from and to aduit record
           --count(distinct aud.incident_id) responses,
           sum(decode(aud.incident_owner_id,to_dttm.old_incident_owner_id,
                   decode(aud.incident_audit_id,to_dttm.incident_audit_id,
                           nvl(aud.inc_responded_by_date,aud.incident_resolved_date),to_dttm.creation_date)
                          -decode(from_dttm.old_incident_date,null,from_dttm.incident_date,from_dttm.creation_date),
                      0)
              ) * 1440     waiting_on_me,
           sum(decode(aud.incident_owner_id,to_dttm.old_incident_owner_id,
                           0,
                   decode(aud.incident_audit_id,to_dttm.incident_audit_id,
                           nvl(aud.inc_responded_by_date,aud.incident_resolved_date),to_dttm.creation_date)
                          -decode(from_dttm.old_incident_date,null,from_dttm.incident_date,from_dttm.creation_date)
                           )) * 1440 not_waiting_on_me
          from cs_incidents_audit_b aud      , --this is audit rec for response
               cs_incidents_audit_b to_dttm  , -- to date time
               cs_incidents_audit_b from_dttm -- ,from date time
  /* the pair of from_dttm to to_dttm will give the durating in which an agent
     owned a serveice request. */
         where aud.incident_audit_id =
                   ( select max(incident_audit_id)
                       from cs_incidents_audit_b aud_in
                      where aud_in.incident_id = aud.incident_id
                        and aud_in.creation_date between p_from_date
                                                     and p_to_date
                        and nvl(nvl(aud_in.old_inc_responded_by_date,aud_in.old_incident_resolved_date),l_dt) <>
                                                   nvl(nvl(aud_in.inc_responded_by_date,aud_in.incident_resolved_date),l_dt)
                        and (aud_in.inc_responded_by_date is not null or
                             aud_in.incident_resolved_date is not null)
                        -- above cond is needed to make sure that sr is
                        -- responded. if this cond is not there then inc_responded_by_date
                        -- as null to may get selected which is clearly not
                        -- responded condition.
                   )
         -- above query will insure that selected response is the last response
           and to_dttm.incident_id        = aud.incident_id
           and to_dttm.creation_date     <= aud.creation_date
           and (to_dttm.incident_audit_id = aud.incident_audit_id or
                (nvl(to_dttm.old_incident_owner_id,-1) <>
                                           nvl(to_dttm.incident_owner_id,-1) and
                 to_dttm.creation_date >= to_dttm.incident_date)
               )
           -- above will insure that to_dttm start from responded audit rec
           and aud.incident_id = from_dttm.incident_id
           /*
           and (nvl(from_dttm.old_incident_owner_id,-1) <>
                                           nvl(from_dttm.incident_owner_id,-1) or
                nvl(from_dttm.old_incident_date,trunc(sysdate-300)) <>
                                           nvl(from_dttm.incident_date,trunc(sysdate-300))
               )
           */
           and from_dttm.incident_audit_id =
                   (select max(incident_audit_id) from cs_incidents_audit_b x
                     where x.incident_id = aud.incident_id
                       and ((nvl(x.old_incident_owner_id,-1) <>
                                       nvl(x.incident_owner_id,-1) and
                            x.creation_date >= x.incident_date) or
                            nvl(x.old_incident_date,trunc(sysdate-300)) <>
                                           nvl(x.incident_date,trunc(sysdate-300))
                           )
                       and x.creation_date < to_dttm.creation_date
                   )
         group by aud.incident_owner_id,
                  aud.group_id,
                  aud.incident_severity_id,
                  trunc(nvl(aud.inc_responded_by_date,aud.incident_resolved_date))
        ;
  cursor c_resp_times_rev is
    select /*+ ORDERED */
           nvl(aud.incident_owner_id,-1)   incident_owner_id,
           nvl (aud.incident_severity_id,-1) incident_severity_id,
           nvl (aud.group_id,-1)             owner_group_id,
           trunc(nvl(aud.inc_responded_by_date,aud.incident_resolved_date)) inc_responded_by_date,
           sum(decode(aud.incident_owner_id,to_dttm.old_incident_owner_id,
                 csy_kpi_pkg.get_agents_time(to_dttm.old_incident_owner_id,
                   decode(from_dttm.old_incident_date,null,from_dttm.incident_date,from_dttm.creation_date),
                   decode(aud.incident_audit_id,to_dttm.incident_audit_id,
                           nvl(aud.inc_responded_by_date,aud.incident_resolved_date),
                           to_dttm.creation_date)),0)
              ) * 1440     resp_time,
           -- we need to select distinct because each responded
           -- audit will be joined with mulitple from and to aduit record
           --count(distinct aud.incident_id) responses,
           sum(decode(aud.incident_owner_id,to_dttm.old_incident_owner_id,
                   decode(aud.incident_audit_id,to_dttm.incident_audit_id,
                           nvl(aud.inc_responded_by_date,aud.incident_resolved_date),to_dttm.creation_date)
                           - decode(from_dttm.old_incident_date,null,from_dttm.incident_date,from_dttm.creation_date),
                      0)
              ) * 1440     waiting_on_me,
           sum(decode(aud.incident_owner_id,to_dttm.old_incident_owner_id,
                           0,
                   decode(aud.incident_audit_id,to_dttm.incident_audit_id,
                           nvl(aud.inc_responded_by_date,aud.incident_resolved_date),to_dttm.creation_date)
                           - decode(from_dttm.old_incident_date,null,from_dttm.incident_date,from_dttm.creation_date)
                           )) * 1440 not_waiting_on_me
           /* replaced with above selection
           sum(decode(aud.incident_owner_id,to_dttm.old_incident_owner_id,
                           to_dttm.creation_date-from_dttm.creation_date,0))
                                                    * 1440       waiting_on_me,
           sum(decode(aud.incident_owner_id,to_dttm.old_incident_owner_id,
                           0,to_dttm.creation_date-from_dttm.creation_date))
                                                    * 1440   not_waiting_on_me
          */
          from cs_incidents_audit_b curr_resp,
               cs_incidents_audit_b aud      , --this is audit rec for prior response
               cs_incidents_audit_b to_dttm  , -- to date time
               cs_incidents_audit_b from_dttm -- ,from date time
  /* the pair of from_dttm to to_dttm will give the durating in which an agent
     owned a serveice request. */
         where aud.incident_audit_id =
                   ( select max(incident_audit_id)
                       from cs_incidents_audit_b aud_in
                      where aud_in.incident_id = curr_resp.incident_id
                        and aud_in.creation_date < p_from_date
                        and nvl(nvl(aud_in.old_inc_responded_by_date,aud_in.old_incident_resolved_date),l_dt) <>
                                                   nvl(nvl(aud_in.inc_responded_by_date,aud_in.incident_resolved_date),l_dt)
                        and (aud_in.inc_responded_by_date is not null or
                             aud_in.incident_resolved_date is not null)
                        -- above cond is needed to make sure that sr is
                        -- responded. if this cond is not there then inc_responded_by_date
                        -- as null to may get selected which is clearly not
                        -- responded condition.
                   )
           and curr_resp.incident_audit_id =
                   ( select max(incident_audit_id)
                       from cs_incidents_audit_b aud_in
                      where aud_in.incident_id = curr_resp.incident_id
                        and aud_in.creation_date between p_from_date
                                                     and p_to_date
                        and nvl(nvl(aud_in.old_inc_responded_by_date,aud_in.old_incident_resolved_date),l_dt) <>
                                                   nvl(nvl(aud_in.inc_responded_by_date,aud_in.incident_resolved_date),l_dt)
                        and (aud_in.inc_responded_by_date is not null or
                             aud_in.inc_responded_by_date is not null )
                        -- above cond is needed to make sure that sr is
                        -- responded. if this cond is not there then inc_responded_by_date
                        -- as null to may get selected which is clearly not
                        -- responded condition.
                   )
           and curr_resp.incident_id = aud.incident_id
           -- This make sure that earlier resp to current response is selected
         -- above query will insure that selected response is the last response
           and to_dttm.incident_id        = aud.incident_id
           and to_dttm.creation_date     <= aud.creation_date
           and (to_dttm.incident_audit_id = aud.incident_audit_id or
                (nvl(to_dttm.old_incident_owner_id,-1) <>
                                           nvl(to_dttm.incident_owner_id,-1) and
                 to_dttm.creation_date >= to_dttm.incident_date)
               )
           -- above will insure that to_dttm start from responded audit rec
           and from_dttm.incident_id = curr_resp.incident_id
           /*
           and (nvl(from_dttm.old_incident_owner_id,-1) <>
                                           nvl(from_dttm.incident_owner_id,-1) or
                nvl(from_dttm.old_incident_date,trunc(sysdate-300)) <>
                                           nvl(from_dttm.incident_date,trunc(sysdate-300))
               )
           */
           and from_dttm.incident_audit_id =
                   (select max(incident_audit_id) from cs_incidents_audit_b x
                     where x.incident_id = curr_resp.incident_id
                       and ((nvl(x.old_incident_owner_id,-1) <>
                                       nvl(x.incident_owner_id,-1) and
                            x.creation_date >= x.incident_date) or
                            nvl(x.old_incident_date,trunc(sysdate-300)) <>
                                           nvl(x.incident_date,trunc(sysdate-300))
                           )
                       and x.creation_date < to_dttm.creation_date
                   )
         group by aud.incident_owner_id,
                  aud.group_id,
                  aud.incident_severity_id,
                  trunc(nvl(aud.inc_responded_by_date,aud.incident_resolved_date))
        ;
    l_owner_id       cs_incidents_all_b.incident_owner_id    % type;
    l_sev_id         cs_incidents_all_b.incident_severity_id % type;
    l_group_id       cs_incidents_all_b.owner_group_id       % type;
    l_summ_dt        cs_incidents_all_b.close_date           % type;
    l_resp_time      number;
    l_no_of_resp     number;
    l_wait_on_me     number;
    l_wait_on_others number;
begin
  l_dt := trunc(sysdate) - 10000;
  open c_resp_times;
  loop
    fetch c_resp_times into l_owner_id, l_sev_id, l_group_id,
                           l_summ_dt, l_resp_time,
                           l_wait_on_me, l_wait_on_others;
    if (c_resp_times%notfound) then exit; end if;
    upload_resp_and_resl(p_incident_owner_id    =>l_owner_id,
                         p_owner_group_id       => l_group_id,
                         p_incident_severity_id => l_Sev_id,
                         p_summary_date         => l_summ_dt,
                         p_owner_type           => 'A',
 p_requests_responded      => 0,
 p_requests_resolved       => 0,
 p_resolve_time            => 0,
 p_wait_on_agent_resl      => 0,
 p_wait_on_int_org_resl    => 0,
 p_wait_on_ext_org_resl    => 0,
 p_wait_on_support_resl    => 0,
 p_wait_on_customer_resl   => 0,
 p_resp_sla_missed         => 0,
 p_resl_sla_missed         => 0,
 p_beginning_backlog       => null,
 p_ending_backlog          => null,
 p_sr_assigned             => 0,
 p_sr_reassigned_to_others => 0,
                         p_response_time        => l_resp_time,
                         p_wait_on_agent_resp   => l_wait_on_me,
                         p_wait_on_others_resp  => l_wait_on_others);
    /*
    dbms_output.put_line('Time:Owner:'|| to_char(l_owner_id) || ' ,Resptm:'||to_char(l_resp_time) ||
                      ', Date:' ||to_char(l_summ_dt,'dd-mon-yy'));
      */
  end loop;
  close c_resp_times;
  debug('After Sr Response time:'||to_char(sysdate,'hh24:mi:ss'));
  --
  -- Now reverse the response time if an incident was responded earlier
  open c_resp_times_rev;
  loop
    fetch c_resp_times_rev into l_owner_id, l_sev_id, l_group_id,
                           l_summ_dt, l_resp_time,
                           l_wait_on_me, l_wait_on_others;
    if (c_resp_times_rev%notfound) then exit; end if;
    upload_resp_and_resl(p_incident_owner_id    => l_owner_id,
                         p_owner_group_id       => l_group_id,
                         p_incident_severity_id => l_Sev_id,
                         p_summary_date         => l_summ_dt,
                         p_owner_type           => 'A',
 p_requests_responded      => 0,
 p_requests_resolved       => 0,
 p_resolve_time            => 0,
 p_wait_on_agent_resl      => 0,
 p_wait_on_int_org_resl    => 0,
 p_wait_on_ext_org_resl    => 0,
 p_wait_on_support_resl    => 0,
 p_wait_on_customer_resl   => 0,
 p_resp_sla_missed         => 0,
 p_resl_sla_missed         => 0,
 p_beginning_backlog       => null,
 p_ending_backlog          => null,
 p_sr_assigned             => 0,
 p_sr_reassigned_to_others => 0,
                         p_response_time        => l_resp_time *-1,
                         p_wait_on_agent_resp   => l_wait_on_me*-1,
                         p_wait_on_others_resp  => l_wait_on_others*-1);
 /*
    dbms_output.put_line('REV-Time:Owner:'|| to_char(l_owner_id) || ' ,Resptm:'||to_char(nvl(l_resp_time,-9)) ||
                      ', Date:' ||to_char(l_summ_dt,'dd-mon-yy'));
    */
  end loop;
  close c_resp_times_rev;
  debug('After Sr Response time Reversal:'||to_char(sysdate,'hh24:mi:ss'));
  --
  -- Get number of requests responded
  --
  open c_responses;
  loop
    fetch c_responses into l_owner_id, l_sev_id, l_group_id,
                           l_summ_dt,  l_no_of_resp, l_sla_missed;
    if (c_responses%notfound) then exit; end if;
    upload_resp_and_resl(p_incident_owner_id    =>l_owner_id,
                         p_owner_group_id       => l_group_id,
                         p_incident_severity_id => l_Sev_id,
                         p_summary_date         => l_summ_dt,
                         p_owner_type           => 'A',
 p_response_time           => 0,
 p_wait_on_agent_resp      => 0,
 p_wait_on_others_resp     => 0,
 p_requests_resolved       => 0,
 p_resolve_time            => 0,
 p_wait_on_agent_resl      => 0,
 p_wait_on_int_org_resl    => 0,
 p_wait_on_ext_org_resl    => 0,
 p_wait_on_support_resl    => 0,
 p_wait_on_customer_resl   => 0,
 p_resl_sla_missed         => 0,
 p_beginning_backlog       => null,
 p_ending_backlog          => null,
 p_sr_assigned             => 0,
 p_sr_reassigned_to_others => 0,
                         p_requests_responded   => l_no_of_resp,
                         p_resp_sla_missed      => l_sla_missed);
    /*
    dbms_output.put_line('Owner:'|| to_char(l_owner_id) || ' ,Resp:'||to_char(l_no_of_resp) ||
                      ', Date:' ||to_char(l_summ_dt,'dd-mon-yy'));
     */
  end loop;
  close c_responses;
  debug('After Sr Response Count:'||to_char(sysdate,'hh24:mi:ss'));
  --
  -- Get number of requests responded to be reversed
  --
  open c_responses_rev;
  loop
    fetch c_responses_rev into l_owner_id, l_sev_id, l_group_id,
                           l_summ_dt, l_no_of_resp,l_sla_missed;
    if (c_responses_rev%notfound) then exit; end if;
    upload_resp_and_resl(p_incident_owner_id    =>l_owner_id,
                         p_owner_group_id       => l_group_id,
                         p_incident_severity_id => l_Sev_id,
                         p_summary_date         => l_summ_dt,
                         p_owner_type           => 'A',
 p_response_time           => 0,
 p_wait_on_agent_resp      => 0,
 p_wait_on_others_resp     => 0,
 p_requests_resolved       => 0,
 p_resolve_time            => 0,
 p_wait_on_agent_resl      => 0,
 p_wait_on_int_org_resl    => 0,
 p_wait_on_ext_org_resl    => 0,
 p_wait_on_support_resl    => 0,
 p_wait_on_customer_resl   => 0,
 p_resl_sla_missed         => 0,
 p_beginning_backlog       => null,
 p_ending_backlog          => null,
 p_sr_assigned             => 0,
 p_sr_reassigned_to_others => 0,
                         p_requests_responded   => l_no_of_resp*-1,
                         p_resp_sla_missed      => l_sla_missed*-1);
    /*
    dbms_output.put_line('REV: Owner:'|| to_char(l_owner_id) || ' ,Resp:'||to_char(l_no_of_resp) ||
                      ', Date:' ||to_char(l_summ_dt,'dd-mon-yy'));
    */
  end loop;
  close c_responses_rev;
  debug('After Sr Response Count Reversal:'||to_char(sysdate,'hh24:mi:ss'));
  --
  exception
   when others then
     fnd_file.put_line(fnd_file.log,'Error:'||sqlerrm);
     raise fnd_api.g_exc_unexpected_error;
end;
procedure update_group_data (p_from_date date,
                              p_to_date  date) is
  cursor c_group_data is
    select owner_group_id,
           summary_date,
           incident_severity_id,
           sum(total_response_time         ) resp_time,
           sum(total_requests_responded    ) req_resp,
           sum(total_wait_on_agent_resp    ) wait_on_agent_resp,
           sum(total_wait_on_others_resp   ) wait_on_others_resp,
           sum(total_requests_resolved     ) req_resl,
           sum(total_resolve_time          ) resl_time,
           sum(total_wait_on_agent_resl    ) wait_on_agent_resl,
           sum(total_wait_on_int_org_resl  ) wait_on_int_org,
           sum(total_wait_on_ext_org_resl  ) wait_on_ext_org,
           sum(total_wait_on_support_resl  ) wait_on_support,
           sum(total_wait_on_customer_resl ) wait_on_customer,
           sum(total_resp_sla_missed       ) resp_sla,
           sum(total_resl_sla_missed       ) resl_sla,
           sum(beginning_backlog           ) begblog,
           sum(ending_backlog              ) endblog
     from csy_response_resolutions
    where summary_date between p_from_date and p_to_date
      and owner_type = 'A'
    group by owner_group_id,
             summary_date,
             incident_severity_id;
begin
   for l_rec in c_group_data loop
       update csy_response_resolutions
          set total_response_time         = l_rec.resp_time,
              total_requests_responded    = l_rec.req_resp,
              total_wait_on_agent_resp    = l_rec.wait_on_agent_resp,
              total_wait_on_others_resp   = l_rec.wait_on_others_resp,
              total_requests_resolved     = l_rec.req_resl,
              total_resolve_time          = l_rec.resl_time,
              total_wait_on_agent_resl    = l_rec.wait_on_agent_resl,
              total_wait_on_int_org_resl  = l_rec.wait_on_int_org,
              total_wait_on_ext_org_resl  = l_rec.wait_on_ext_org,
              total_wait_on_support_resl  = l_rec.wait_on_support,
              total_wait_on_customer_resl = l_rec.wait_on_customer,
              total_resp_sla_missed       = l_rec.resp_sla,
              total_resl_sla_missed       = l_rec.resl_sla,
              beginning_backlog           = l_rec.begblog,
              ending_backlog              = l_rec.endblog
        where summary_date         = l_rec.summary_date
          and owner_group_id       = l_rec.owner_group_id
          and owner_type           = 'G'
          and incident_owner_id    = -1
          and incident_severity_id = l_rec.incident_severity_id;
       if (sql%notfound) then
          insert into csy_response_resolutions
                 (summary_date,
                  incident_owner_id,
                  incident_severity_id,
                  owner_group_id,
                  owner_type,
                  TOTAL_RESPONSE_TIME           ,
                  TOTAL_REQUESTS_RESPONDED      ,
                  TOTAL_WAIT_ON_AGENT_RESP      ,
                  TOTAL_WAIT_ON_OTHERS_RESP     ,
                  TOTAL_REQUESTS_RESOLVED       ,
                  TOTAL_RESOLVE_TIME            ,
                  TOTAL_WAIT_ON_AGENT_RESL      ,
                  TOTAL_WAIT_ON_INT_ORG_RESL    ,
                  TOTAL_WAIT_ON_EXT_ORG_RESL    ,
                  TOTAL_WAIT_ON_SUPPORT_RESL    ,
                  TOTAL_WAIT_ON_CUSTOMER_RESL   ,
                  TOTAL_RESP_SLA_MISSED         ,
                  TOTAL_RESL_SLA_MISSED         ,
                  BEGINNING_BACKLOG             ,
                  ENDING_BACKLOG                ,
               last_update_date              ,
               last_updated_by               ,
               creation_date                 ,
               created_by                    ,
               last_update_login             ,
               program_id                    ,
               program_login_id              ,
               program_application_id        ,
               request_id                    )
          values (l_rec.summary_date,
                  -1,
                  l_rec.incident_severity_id,
                  l_rec.owner_group_id,
                  'G',
                  l_rec.resp_time,
                  l_rec.req_resp,
                  l_rec.wait_on_agent_resp,
                  l_rec.wait_on_others_resp,
                  l_rec.req_resl,
                  l_rec.resl_time,
                  l_rec.wait_on_agent_resl,
                  l_rec.wait_on_int_org,
                  l_rec.wait_on_ext_org,
                  l_rec.wait_on_support,
                  l_rec.wait_on_customer,
                  l_rec.resp_sla,
                  l_rec.resl_sla,
                  l_rec.endblog,
                  l_rec.begblog,
               sysdate                       ,
               g_user_id                     ,
               sysdate                       ,
               g_user_id                     ,
               g_login_user_id               ,
               g_conc_program_id             ,
               g_conc_login_id               ,
               g_conc_appl_id                ,
               g_conc_request_id  );
       end if;
   end loop;
end update_group_data;
-----------------------------------
procedure incremental_data_load(p_errbuf out nocopy varchar2,
                                p_retcode out nocopy number) is
  l_from_date date;
  l_to_date   date;
  l_ret_val   boolean;
begin
  g_user_id         := fnd_global.user_id;
  g_login_user_id   := fnd_global.login_id;
  g_conc_program_id := fnd_global.conc_program_id;
  g_conc_login_id   := fnd_global.conc_login_id;
  g_conc_appl_id    := fnd_global.prog_appl_id;
  g_conc_request_id := fnd_global.conc_request_id;
  select to_date(fnd_profile.value('CS_CSY_LAST_PROGRAM_RUN_DATE'),
                 'YYYYMMDD HH24:MI:SS')
    into l_from_date
    from dual;
  if (l_from_date is null) then
     fnd_file.put_line(fnd_file.log,'Please Run: KPI summary: Initial Data Laod Set');
     p_errbuf := '"KPI Summary: Initial Data load Set" has never been run.';
     p_errbuf := p_errbuf || ' So Please Run:"KPI summary: Initial Data Load Set" before running Incremental Data Load';
     p_retcode := 2;
     return;
  end if;
  debug('From Date before Addition of 1 second:'||
                            to_char(l_from_date,'dd-mon-yyyy hh24:mi:ss'));
  l_from_date := l_from_date + 1/86400;
  debug('From Date after  Addition of 1 second:'||
                            to_char(l_from_date,'dd-mon-yyyy hh24:mi:ss'));
  l_to_date := sysdate;
  debug('Before Sr assignments:'||to_char(sysdate,'hh24:mi:ss'));
  get_sr_agent_assignments    (l_from_date, l_to_date);
  debug('After Sr assignments:'||to_char(sysdate,'hh24:mi:ss'));
  get_sr_backlog        (l_from_date, l_to_date);
  debug('After Sr backlog    :'||to_char(sysdate,'hh24:mi:ss'));
  get_sr_resolutions    (l_from_date, l_to_date);
  debug('After Sr resolutions:'||to_char(sysdate,'hh24:mi:ss'));
  get_response_timings  (l_from_date, l_to_date);
  debug('After Sr Resp Timing:'||to_char(sysdate,'hh24:mi:ss'));
  get_resolution_timings(l_from_date, l_to_date);
  debug('After Sr Resl timing:'||to_char(sysdate,'hh24:mi:ss'));
  /* we need to truncate l_from_date. reason l_from_date will be like 10-oct-2003 10:00:00
     so it will not sum the data for 10-oct-2003
  */
  --update_group_data     (trunc(l_from_date), l_to_date);
  --change above line with the line below. Suppose a service request is reopened after 10
  --days and then resolved. Earlier resolution data will be corrected for the agent but
  -- for group it will not get corrected due to from_date value. So changing from date to
  -- last 365 days since kpi displays data only for up to last 365 days
  update_group_data     (l_to_date-367, l_to_date);
  debug('After Group Data    :'||to_char(sysdate,'hh24:mi:ss'));
  l_ret_val := fnd_profile.save('CS_CSY_LAST_PROGRAM_RUN_DATE',
                                to_char(l_to_date,'YYYYMMDD hh24:mi:ss'),
                                'SITE');
  if (l_ret_val) then
     --refresh_mvs(p_errbuf,p_retcode);
     commit;
  else
     rollback;
     --give error message;
  end if;

end;
----------------------------
procedure initial_data_load(p_errbuf out nocopy varchar2,
                                p_retcode out nocopy number) is
  l_min_date date;
  l_ret_val   boolean;
begin
  /**
   select min(creation_date) - 1
     into l_min_date
    from cs_incidents_audit_b;
  */
  delete from csy_response_resolutions;
  delete from csy_resolution_qlty;
  commit;
  l_min_date := trunc(sysdate) - 370;
  l_ret_val := fnd_profile.save('CS_CSY_LAST_PROGRAM_RUN_DATE',
                                to_char(l_min_date,'YYYYMMDD hh24:mi:ss'),
                                'SITE');
  if (l_ret_val) then
     commit;
     incremental_data_load(p_errbuf, p_retcode );
  else
     rollback;
     --give error message;
  end if;
end;
---------------------------------------------------
procedure refresh_mvs(p_errbuf out nocopy varchar2,
                      p_retcode out nocopy number) is
begin
   dbms_mview.refresh('CSY_AGENT_RESPN_RESOL_MV,CSY_GROUP_RESPN_RESOL_MV','cc');
   dbms_mview.refresh('CSY_RESOLUTION_QUALITY_MV','c');

end refresh_mvs;
----------------------------
function sev_names (p_imp_lvl number) return varchar2 is
  l_imp_lvl_rnk number;
cursor c_severities is
   select  name
         from cs_incident_severities_vl
    where importance_level = p_imp_lvl
      and trunc(sysdate) between nvl(start_date_active,sysdate-1) and nvl(end_date_active,sysdate+1)
      and incident_subtype = 'INC';
  --
  l_id      cs_incident_severities_vl.incident_Severity_id % type;
  l_name    cs_incident_severities_vl.name                 % type;
  l_imp_lvl cs_incident_severities_vl.importance_level     % type;
  l_rnk     number;
  l_all_sev varchar2(2000);
  l_count   number;
  l_min_lvl  number;
  l_loop_counter number;
  --
begin
  select min(importance_level) into l_min_lvl
    from cs_incident_severities_b
   where trunc(sysdate) between nvl(start_date_active,sysdate-1) and nvl(end_date_active,sysdate+1)
      and incident_subtype = 'INC';
  l_count := 0;
  open  c_severities;
  loop
     fetch c_severities into  l_name;
     exit when c_severities%notfound;
     if (l_count = 0) then
        l_all_sev := l_name;
     else
        l_all_sev := l_all_sev || ', ' || l_name;
     end if;
     l_count := l_count + 1;
  end loop;
  close c_severities;
  if (l_min_lvl <> p_imp_lvl) then
     l_all_sev := l_all_sev || ' +';
  else
     l_all_sev := l_all_sev || ';';
  end if;

  return l_all_sev;
end sev_names;
end ;

/
