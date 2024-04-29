--------------------------------------------------------
--  DDL for Package Body BIV_VERSION_SPECIFIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIV_VERSION_SPECIFIC_PKG" AS
	-- $Header: bivvrsnb.pls 115.1 2003/02/18 23:39:16 smisra noship $ */
function get_sr_table return varchar2 as
begin
   return('cs_incidents_all_b');
end;
procedure set_update_program( p_sr_rec in out nocopy
                           CS_ServiceRequest_PVT.service_request_rec_type) as
begin
  p_sr_rec.last_update_program_code := 'BIV_SR_UPDATE';
end;
procedure status_lov(p_sr_id number,
                     p_lov_sttmnt out nocopy varchar2) as
  l_status_group_id cs_sr_type_mapping.status_group_id % type;
  l_type_id         cs_incidents_all_b.incident_type_id % type;
  l_old_status_id   cs_incident_statuses_b.incident_status_id % type;
  --
  cursor c_type is
  select incident_type_id, incident_status_id
    from cs_incidents_all_b
   where incident_id = p_sr_id;
  ---
  cursor c_status_group1 is
  select status_group_id
    from cs_sr_type_mapping
   where incident_type_id = l_type_id
     and responsibility_id = fnd_profile.value('RESP_ID');
  --
  cursor c_status_group2 is
  select status_group_id
    from cs_incident_types_b
   where incident_type_id = l_type_id;
  --
  cursor c_trans_ind is
  select transition_ind
    from cs_sr_status_groups_b
   where status_group_id = l_status_group_id
    and sysdate between nvl(start_date,sysdate-1) and nvl(end_date,sysdate+1);
  l_trans_id    cs_sr_status_groups_b.transition_ind % type;
  l_lov_sttmnt1 varchar2(2000);
  l_lov_sttmnt2 varchar2(2000);
  l_lov_sttmnt3 varchar2(2000);
begin
  open c_type;
  fetch c_type into l_type_id, l_old_status_id;
  close c_type;
  -- set lov statements
  l_lov_sttmnt1 := 'select incident_status_id, name, ''&nbsp;''
                        from cs_incident_statuses_vl
                       where incident_subtype = ''INC''
                         and sysdate between nvl(start_date_active,sysdate-1)
                                         and nvl(end_date_active,sysdate+1)
                         and upper(name) like upper(?)
                        order by name asc';
  -- used when trans_id is Y
  l_lov_sttmnt2 := '
        select st.incident_status_id, st.name, ''&nbsp;''
          from cs_incident_statuses st,
               cs_sr_status_transitions st_tran
         where st_tran.from_incident_status_id = st.incident_status_id
           and st_tran.from_incident_status_id=' || to_char(l_old_status_id) ||'
           and trunc(sysdate) between trunc(nvl(st.start_date_active, sysdate))
                                  and trunc(nvl(st.end_date_active, sysdate))
           and trunc(sysdate) between trunc(nvl(st_tran.start_date, sysdate))
                                 and trunc(nvl(st_tran.end_date, sysdate))
           and upper(st.name) like upper(?)
      union
        select st.incident_status_id, st.name, ''&nbsp;''
          from  cs_incident_statuses st
         where st.incident_status_id = ' || to_char(l_old_status_id) ||'
      order by 2';
  -- used when trans_id is NOT Y
  l_lov_sttmnt3 := '
       select st.incident_status_id, st.name, ''&nbsp;''
         from cs_incident_statuses st,
              cs_incident_types_b typ,
              cs_sr_allowed_statuses allowd_st
        where typ.incident_type_id = ' || to_char(l_type_id) || '
          and typ.status_group_id = allowd_st.status_group_id
          and allowd_st.incident_status_id = st.incident_status_id
          and trunc(sysdate) between trunc(nvl(allowd_st.start_date,sysdate))
                                 and trunc(nvl(allowd_st.end_date,sysdate))
          and trunc(sysdate) between trunc(nvl(st.start_date_active, sysdate))
                                 and trunc(nvl(st.end_date_active, sysdate))
          and upper(st.name) like upper(?)
       order by 2';
  if (l_type_id is null) then
     p_lov_sttmnt := l_lov_sttmnt1;
  else
    open c_status_group1;
    fetch c_status_group1 into l_status_group_id;
    if (c_status_group1%notfound or l_status_group_id is null) then
       open  c_status_group2;
       fetch c_status_group2 into l_status_group_id;
       close c_status_group2;
    end if;
    close c_status_group1;
    if (l_status_group_id is null) then
       p_lov_sttmnt := l_lov_sttmnt1;
    else
       open  c_trans_ind;
       fetch c_trans_ind into l_trans_id;
       close c_trans_ind;
       if (nvl(l_trans_id,'N') = 'Y') then
          p_lov_sttmnt := l_lov_sttmnt2;
       else
          p_lov_sttmnt := l_lov_sttmnt3;
       end if;
    end if; -- for status group id
  end if; -- for type id

  biv_core_pkg.biv_debug(p_lov_sttmnt,'STATUS_LOV');
  exception
    when no_data_found then
        p_lov_sttmnt := l_lov_sttmnt1;
end;
end;

/
