--------------------------------------------------------
--  DDL for Package Body BIV_SR_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIV_SR_DETAILS_PKG" as
/* $Header: bivcsrdb.pls 120.3 2006/02/14 23:21:59 ngmishra noship $ */
       -- get data for reopen
function get_last_run_time return date is
  l_dt date;
begin
  select max(last_update_date) into l_dt
    from biv_sr_summary;
  return nvl(l_dt,sysdate - 3650);
  exception
     when others then
       return sysdate - 365*10;
end;
procedure clear_temp_tables (errbuf  out nocopy varchar2,
                             retcode out nocopy number) is
begin
   delete from biv_tmp_bin;
   delete from biv_tmp_rt1;
   delete from biv_tmp_rt2;
   delete from biv_tmp_hs1;
   delete from biv_tmp_hs2;
   delete from biv_debug;
   commit;
end;
-----------------------------------------
procedure get_data (errbuf  out nocopy varchar2,
                    retcode out nocopy number) is
 cursor c_reopen_sr is
    select au1.incident_id,min(au1.last_update_date)
      from cs_incidents_audit_b au1,
           cs_incident_statuses_b stat1,
           cs_incident_statuses_b stat2
     where au1.change_incident_status_flag = 'Y'
       and au1.old_incident_status_id = stat1.incident_status_id
       and au1.incident_status_id     = stat2.incident_status_id
       and nvl(stat1.close_flag,'N')  = 'Y'
       and nvl(stat2.close_flag,'N') <> 'Y'
     group by au1.incident_id;
  l_incident_id   cs_incidents_all_b.incident_id % type;
  l_incident_date date;
  l_reopen_date   date;
  l_reclose_date  date;
  l_resp_time     number;
  l_last_prog_run date;
  l_curr_time     date := sysdate;

  l_user_id       number := fnd_global.user_id;
  l_login_id      number := fnd_global.login_id;
  cursor c_sreqs is
    select incident_id, incident_date
      from cs_incidents_all_b
     where last_update_date >= l_last_prog_run;
begin
  l_last_prog_run := get_last_run_time;
  --dbms_output.put_line('Last time program was run on ' ||
  --                    to_char(l_last_prog_run,'dd-mon-yyyy hh24:mi:ss'));
  insert into biv_sr_summary(incident_id,
                             arrival_time,
                             last_update_date,
                             creation_date,
                             last_updated_by,
                             created_by,
                             last_update_login
                             )
    select incident_id,
           to_number(to_char(trunc(incident_date,'HH24'),'HH24')) +
           decode(sign(to_number(to_char(trunc(incident_date,'MI'),'MI'))-30),
                              1,.5,0),
           l_curr_time,
           l_curr_time,
           l_user_id,
           l_user_id,
           l_login_id
      from cs_incidents_all_b sr
     where not exists ( select 1 from biv_sr_summary sm
                         where sr.incident_id = sm.incident_id)
     ;
  --dbms_output.put_line('Number of New incidents inserted in Summary Table :'||
  --                              to_char(sql%rowcount));
  open c_reopen_sr;
  loop
     fetch c_reopen_sr into l_incident_id, l_reopen_date;
     if c_reopen_sr % notfound then exit; end if;
     get_reclose_date(l_incident_id, l_reopen_date, l_reclose_date);
     update_reopen_reclose_date(l_incident_id,l_reopen_date,l_reclose_date);
  end loop;
  close c_reopen_sr;
  --
  -- update response time
  open c_sreqs;
  loop
     fetch c_sreqs into l_incident_id, l_incident_date;
     if c_sreqs % notfound then exit; end if;
     l_resp_time := get_response_time(l_incident_id, l_incident_date);
     if (l_resp_time is not null) then
        update biv_sr_summary
           set response_time = l_resp_time
         where incident_id = l_incident_id;
     end if;
  end loop;
  --dbms_output.put_line('No of Incidents update in Summary Table:'||
  --                         to_char(c_sreqs%rowcount));
  close c_sreqs;
  -- End of response time update
  --
  update_escalation_level;
  --get_group_levels(errbuf, retcode);
  clear_temp_tables(errbuf, retcode);
end;
------------------- End of Get Data ------------------
procedure get_reclose_date(p_incident_id         number,
                           p_reopen_date         date,
                           x_reclose_date in out nocopy date) as
begin
  select min(au2.last_update_date)
    into x_reclose_date
    from cs_incidents_audit_b au2,
         cs_incident_statuses_b stat3,
         cs_incident_statuses_b stat4
   where au2.incident_id                 = p_incident_id
     and au2.last_update_date            > p_reopen_date
     and au2.change_incident_status_flag = 'Y'
     and au2.old_incident_status_id      = stat3.incident_status_id
     and au2.incident_status_id          = stat4.incident_status_id
     and nvl(stat3.close_flag ,'N')     <> 'Y'
     and nvl(stat4.close_flag ,'N')      = 'Y';
  exception
    when no_data_found then
       x_reclose_date := null;
end;
procedure update_reopen_reclose_date(p_incident_id  number,
                                     p_reopen_date  date,
                                     p_reclose_date date) as
begin
  update biv_sr_summary
     set reopen_date  = p_reopen_date,
         reclose_date = p_reclose_date
   where incident_id  = p_incident_id;
  exception
     when others then null;
end;
procedure update_escalation_level as
 cursor c_escalation is
   select r.object_id, t.escalation_level, owner_id, r.creation_date
     from jtf_task_references_b r,
          jtf_tasks_b           t
    where r.object_type_code = 'SR'
      and r.reference_code   = 'ESC'
      and r.task_id          = t.task_id
      and t.task_type_id     = 22;
  l_incident_id     cs_incidents_all_b.incident_id % type;
  l_esc_level       jtf_tasks_b.escalation_level   % type;
  l_owner_type_code jtf_tasks_b.owner_type_code    % type;
  l_owner_id        jtf_tasks_b.owner_id           % type;
  l_dt              jtf_task_references_b.creation_date % type;

begin
   open c_escalation;
   loop
      fetch c_escalation into l_incident_id, l_esc_level,
                                l_owner_id, l_dt;
      if c_escalation % notfound then exit; end if;
      update biv_sr_summary
         set escalation_level = l_esc_level,
             esc_owner_id     = l_owner_id,
             escalation_date  = l_dt
       where incident_id      = l_incident_id;
   end loop;
   close c_escalation;
end;
procedure get_group_levels (errbuf out nocopy varchar2,
                            retcode out nocopy number  ) is
  /********
  This cursor will give you all the groups which are at top level
  ***************************/
  /*****Hints added and "not exists" replaced with "not in" as part of appsperf bug fix (bug#5029442)********/
  cursor c_parent_groups is
  select/*+index_ffs(grp_out jtf_rs_grp_relations_n1) index_ffs(usg JTF_RS_GROUP_USAGES_U2)*/ distinct related_group_id
  from jtf_rs_grp_relations grp_out,
       jtf_rs_group_usages  usg
  where relation_type = 'PARENT_GROUP'
  and   grp_out.related_group_id = usg.group_id
  and   usg.usage in ( 'METRICS', 'SUPPORT')
  and   grp_out.related_group_id
  not in
  (select/*+index_ffs(grp_in jtf_rs_grp_relations_n1)*/ grp_in.group_id
   from jtf_rs_grp_relations grp_in
   );

/**End of appsperf fix for bug#5029442**/

  l_group_id jtf_rs_groups_b.group_id % type;
begin
 delete from biv_resource_groups;
  open c_parent_groups;
  loop
    begin
      fetch c_parent_groups into l_group_id;
      if c_parent_groups%notfound then exit; end if;
      insert into biv_resource_groups ( group_id, group_level)
                            values ( l_group_id, 1);
      /**  Now top level group has been inserted. The query below will insert
           all the groups at lower hierarchy levels
      ****************/
          --  dbms_output.put_line('Parent Group Id:'|| to_char(l_group_id));
      insert into biv_resource_groups ( group_id, group_level)
        select group_id, level+1
          from jtf_rs_grp_relations
        where relation_type = 'PARENT_GROUP'
         start with related_group_id = l_group_id
       connect by prior group_id = related_group_id;

      exception
         when others then
          null;
          --  dbms_output.put_line('Error for Parent Group Id:'||
          --                                             to_char(l_group_id));
          --  dbms_output.put_line('Error Text:'|| sqlerrm);
    end;
  end loop;
  update biv_resource_groups a
     set usage = (select usage from jtf_rs_group_usages b
                   where a.group_id = b.group_id
                     and usage in ('METRICS', 'SUPPORT')
                     and rownum = 1);
  close c_parent_groups;
  commit;
  insert into biv_resource_groups ( group_id, group_level, usage)
   select a.group_id, 1, b.usage
     from jtf_rs_groups_b a, jtf_rs_group_usages b
    where a.group_id = b.group_id
      and b.usage in ('SUPPORT', 'METRICS')
      and not exists ( select 1
                         from  biv_resource_groups r
                        where r.group_id = a.group_id
                           or r.group_id = a.group_id
                     );

  delete from biv_resource_groups
   where nvl(usage,'XX') not in ('SUPPORT', 'METRICS');

end;
function  get_response_time(p_incident_id number,
                            p_incident_date date)  return number as
  l_update_date date;
begin
   select min(last_update_date)
     into l_update_date
     from cs_incidents_audit_b
    where incident_id = p_incident_id;

   if l_update_date is null then return null;
   else return(l_update_date-p_incident_date);
   end if;
   exception
     when others then return null;
end;
end;

/
