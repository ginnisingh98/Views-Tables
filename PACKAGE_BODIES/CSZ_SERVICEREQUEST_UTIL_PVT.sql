--------------------------------------------------------
--  DDL for Package Body CSZ_SERVICEREQUEST_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSZ_SERVICEREQUEST_UTIL_PVT" as
/* $Header: cszvutlb.pls 120.12 2006/06/30 19:05:24 awwong noship $ */
--
-- -------------------------------------------------------------------------
-- Start of comments
-- UTIL Name   : GET_USER_NAME
-- Type        : Private
-- Description : Given a USER_ID the function will return the username/partyname.
--               Function is used to display the CREATED_BY UserName
-- Parameters  :
-- IN : p_user_id NUMBER Required
-- OUT: Returns UserName  VARCHAR2(360)
-- End of comments
-- -------------------------------------------------------------------------
FUNCTION GET_USER_NAME
( p_user_id IN NUMBER ) RETURN VARCHAR2 IS
   CURSOR c_user
   (p_user_id IN NUMBER
   )IS SELECT   user_name
       FROM fnd_user
       WHERE user_id = p_user_id;

   CURSOR c_resource_name
   (p_user_id IN NUMBER
   )IS SELECT  resource_name
       FROM jtf_rs_resource_extns_vl
       WHERE user_id = p_user_id;

   l_user_name       VARCHAR2(360);
   l_name            VARCHAR2(240);

BEGIN
  IF c_resource_name%ISOPEN
  THEN
      CLOSE c_resource_name;
  END IF;

  OPEN c_resource_name(p_user_id);
  FETCH c_resource_name INTO l_name;

  IF c_resource_name%ISOPEN
  THEN
      CLOSE c_resource_name;
  END IF;


  IF l_name IS NULL
  THEN


/*****************************************************************************
  ** Get the UserName from FND_USER
*****************************************************************************/
  IF c_user%ISOPEN
  THEN
    CLOSE c_user;
  END IF;

  OPEN c_user(p_user_id);
  FETCH c_user INTO l_user_name;

  IF c_user%ISOPEN
  THEN
    CLOSE c_user;
  END IF;

    RETURN l_user_name;
  ELSE
    RETURN l_name;
  END IF;

EXCEPTION
  WHEN OTHERS  THEN
    IF c_resource_name%ISOPEN
    THEN
      CLOSE c_resource_name;
    END IF;

  IF c_user%ISOPEN
  THEN
    CLOSE c_user;
  END IF;
    RETURN 'Not Found';
END GET_USER_NAME;
--
-- -------------------------------------------------------------------------
-- Start of comments
-- UTIL Name   : get_contact_name
-- Type        : Private
-- Description : To get the ContactName based on the ContactPartyId and ContactType
-- Parameters  :
-- IN:  p_contact_type IN  VARCHAR2  Required
-- IN : p_contact_party_id IN  NUMBER Required
-- IN : p_party_id     IN  NUMBER Required

-- Returnvalue:
-- l_contact_name  VARCHAR2(360)
-- End of comments
-- -------------------------------------------------------------------------
FUNCTION get_contact_name
( p_contact_type IN VARCHAR2
 ,p_contact_party_id     IN  NUMBER
 , p_party_id  IN NUMBER
) RETURN VARCHAR2 as
--
  l_contact_name varchar2(360) DEFAULT NULL;
  l_employee_name varchar2(360) DEFAULT NULL;
  l_effective_start_date DATE DEFAULT NULL;
  l_effective_end_date DATE DEFAULT NULL;
--
  cursor c1(param_person_id NUMBER) is
  select full_name,effective_start_date,effective_end_date
  from per_all_people_f
  where person_id = param_person_id
  order by effective_start_date desc;
--
begin
--
  if p_contact_type = 'PERSON' then
    select hz.party_name
    into l_contact_name
    from hz_parties hz
    where hz.party_id = p_party_id;
  elsif p_contact_type = 'PARTY_RELATIONSHIP' then
    select hz.party_name
    into l_contact_name
    from hz_parties hz, hz_relationships rel
    where  rel.party_id = p_contact_party_id
    and  rel.object_id = p_party_id
    and rel.subject_id = hz.party_id
    and rel.subject_type = 'PERSON';
 elsif p_contact_type = 'EMPLOYEE' then
      OPEN c1(p_contact_party_id);
         LOOP
          FETCH c1 into
l_employee_name,l_effective_start_date,l_effective_end_date;
           EXIT WHEN c1%NOTFOUND;
           if (l_effective_start_date is not null and l_employee_name is not
null) then
               l_contact_name := l_employee_name;
             EXIT;
          end if;
         END LOOP;
      CLOSE c1;
  else
     return null;
  end if;
  return l_contact_name;
end;
--
-- -------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : GET_SR_JEOPARDY
--  Type        : Private
--  Description : Returns if Service Request is in Jeopardy or  not
--  Parameters  :
--  IN : p_incident_id    IN  NUMBER Required
--  IN : p_exp_response_date   IN  DATE Required
--  IN : p_exp_resolution_date IN  DATE Required
--  IN : p_actual_response_date     IN DATE Required
--  IN : p_actual_resolution_date   IN DATE Required)

--- Returnvalue:
--  l_sr_jeopardy  VARCHAR2(10)
-- End of comments
-- --------------------------------------------------------------------------------

Function      GET_SR_JEOPARDY
  (  p_incident_id       IN NUMBER,
     p_exp_response_date     IN DATE,
     p_exp_resolution_date   IN DATE,
     p_actual_response_date     IN DATE,
     p_actual_resolution_date   IN DATE)
  RETURN  VARCHAR2 IS

   l_sr_jeopardy                  VARCHAR2(10) := 'NO';
   l_source_id                    NUMBER DEFAULT NULL;
   l_exp_resp_date_buffer         NUMBER DEFAULT NULL;
   l_exp_resoln_date_buffer       NUMBER DEFAULT NULL;

BEGIN

   -- Get the Service:Jeopardy: Expected Response Date Buffer  from the Profiles
     l_exp_resp_date_buffer := fnd_profile.value('CS_CSY_JPARDY_REACT_DATE_BUFFER');
   -- Get the Service: Jeopardy: Expected Resolution Date Buffer  from the Profiles
     l_exp_resoln_date_buffer := fnd_profile.value('CS_CSY_JPARDY_RESL_DATE_BUFFER');

         if(
             ((l_exp_resp_date_buffer is not null) and (p_actual_response_date is null) and (p_exp_response_date is not null) and (p_actual_resolution_date is null) and   ((p_exp_response_date - sysdate) <= l_exp_resp_date_buffer))
                                                        or
             ((l_exp_resoln_date_buffer is not null) and (p_actual_resolution_date is null) and (p_exp_resolution_date is not null) and ((p_exp_resolution_date - sysdate) <= l_exp_resoln_date_buffer))
         ) then

            l_sr_jeopardy := 'YES';
         end if;




 RETURN  l_sr_jeopardy;

 EXCEPTION
   WHEN others THEN
       return 'ERROR IN GET_SR_JEOPARDY' ;
 END; -- Function GET_SR_JEOPARDY
--
-- --------------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : GET_CALCULATED_TIME
--  Type        : Private
--  Description : Returns the Time in Days
--  Parameters  :
--  IN :  p_time     IN NUMBER   Required
--  IN :  p_UOM IN VARCHAR2 Required
--  ReturnValue:
-- l_calculated_time  NUMBER
-- --------------------------------------------------------------------------------
Function     GET_CALCULATED_TIME
  ( p_time IN NUMBER,
    p_UOM IN VARCHAR2)
  RETURN  NUMBER IS

     l_calculated_time       NUMBER :=0 ;

BEGIN

           if (p_time is not null) then
                if (p_UOM = 'DAY') then
                   l_calculated_time := p_time;
                elsif(p_UOM = 'HR') then
                   l_calculated_time := (p_time)/24;
                elsif(p_UOM = 'MIN') then
                   l_calculated_time := (p_time )/(24*60);
                elsif(p_UOM = 'WK') then
                   l_calculated_time := (p_time * 7);
                else
                   l_calculated_time := p_time;
                end if;
         else
           l_calculated_time :=0;
         end if;

    RETURN l_calculated_time;
EXCEPTION
   WHEN OTHERS THEN
       RETURN 'ERROR IN GET_CALCULATED_TIME' ;
END; -- Function GET_CALCULATED_TIME
--
-- --------------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : GET_DEFAULT_SITE
--  Type        : Private
--  Description : Returns the primary billto/shipto address associated with this party
--  Parameters  :
--  IN :  partyId     IN NUMBER   Required
--  IN :  siteUse     IN VARCHAR2 Required
--  ReturnValue: primary billto/shipto address for this party
-- l_default_site VARCHAR2
-- ----------------------------------------------------------------------
Function get_default_site
( partyId  in NUMBER
, site_use in VARCHAR2
) return VARCHAR2 is
--
  l_address VARCHAR2(4000);

  CURSOR default_address (param_party_id NUMBER , param_site_usage VARCHAR2) is
     select l.address1 || decode (l.address2,null,null,',' || l.address2) ||
     decode(l.address3,null,null,', '|| l.address3) || decode(l.address4,null,null,', '|| l.address4) ||
     decode (l.city, null, null, ', '|| l.city) || decode(l.state,null,null,', ' || l.state) ||
     decode(l.province,null,null,', ' || l.province) || decode(l.postal_code,null,null,' '
     || l.postal_code) || decode(l.country,null,null,' ' || l.country)
     from hz_party_sites s, hz_locations l, hz_party_site_uses u
     where s.party_id=param_party_id and s.status='A' and s.location_id=l.location_id and
     s.party_site_id=u.party_site_id and u.site_use_type=param_site_usage
     and u.primary_per_type='Y' and u.status='A';
--
begin
--
  open default_address (partyId, site_use);
  fetch default_address into l_address;
  close default_address;

  return l_address;
exception
  when others then
    IF default_address%ISOPEN THEN
      CLOSE default_address;
    END IF;
    return null;
end get_default_site;
--
-- --------------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : GET_DEFAULT_SITE_ID
--  Type        : Private
--  Description : Returns the site Id for primary billto/shipto address
--  Parameters  :
--  IN :  partyId     IN NUMBER   Required
--  IN :  site_use    IN VARCHAR2 Required
--  ReturnValue:
-- l_default_site  NUMBER
-- --------------------------------------------------------------------------
Function get_default_site_id
( partyId  in NUMBER
, site_use in VARCHAR2
) return NUMBER is
--
  l_site_id NUMBER;

  CURSOR default_site(param_party_id NUMBER, param_site_usage VARCHAR2) is
            select s.party_site_id  from hz_party_sites s,
             hz_party_site_uses u where s.party_id=param_party_id and s.status='A' and
             s.party_site_id=u.party_site_id and u.site_use_type=param_site_usage
             and u.primary_per_type='Y' and u.status='A';
--
begin
--

  open default_site (partyId, site_use);
  fetch default_site into l_site_id;
  close default_site;

  return l_site_id;

exception
  when others then
    IF default_site%ISOPEN THEN
      CLOSE default_site;
    END IF;

    return null;
end get_default_site_id;
--
-- --------------------------------------------------------------------------
-- -------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : task_group_template_mismatch
--  Type        : Private
--  Description : Checks if there is a mismatch in task group template when item,
--                item category, type, problem code change on updating a SR
-- -------------------------------------------------------------------------
procedure task_group_template_mismatch
( p_init_msg_list    in         varchar2   default fnd_api.g_false
, p_old_inv_category in         number
, p_new_inv_category in         number
, p_old_inv_item     in         number
, p_new_inv_item     in         number
, p_old_inc_type     in         number
, p_new_inc_type     in         number
, p_inv_org_id       in         number
, p_incident_id      in         number
, p_old_prob_code    in         varchar2
, p_new_prob_code    in         varchar2
, x_msg_count        out nocopy number
, x_return_status    out nocopy varchar2
, x_msg_data         out nocopy varchar2
) is
--
  l_new_task_group_template_id number;
  l_old_task_group_template_id number;
  l_task_temp_grp_name         varchar2(80);
  l_task_temp_grp_names        varchar2(2000);
  l_found_flag                 varchar2(1)     := 'N';
--
  p_task_template_search_rec   cs_autogen_task_pvt.task_template_search_rec_type;
  l_task_template_group_tbl    cs_autogen_task_pvt.task_template_group_tbl_type;
--
  cursor c_task_template_id is
  select a.template_group_id
  from jtf_tasks_b a, jtf_task_statuses_vl b
  where a.task_status_id = b.task_status_id and
  (nvl(b.closed_flag,'N')  = 'N') and (nvl(b.completed_flag,'N') = 'N') and
  a.source_object_type_code = 'SR' and
  a.source_object_id = p_incident_id;
--
  cursor c_task_temp_grp_name(l_templ_grp_id in number) is
  select template_group_name
  from jtf_task_temp_groups_vl
  where task_template_group_id = l_templ_grp_id;
--
begin
--
  if fnd_api.to_boolean( p_init_msg_list ) then
    fnd_msg_pub.initialize;
  end if;
--
  x_return_status := fnd_api.g_ret_sts_success;
--
  if (p_old_inv_category <> p_new_inv_category) or
     (p_old_inv_item     <> p_new_inv_item)     or
     (p_old_inc_type     <> p_new_inc_type)     or
     (p_old_prob_code    <> p_new_prob_code)    then
       p_task_template_search_rec.incident_type_id  := p_new_inc_type;
       p_task_template_search_rec.organization_id   := p_inv_org_id;
       p_task_template_search_rec.inventory_item_id := p_new_inv_item;
       p_task_template_search_rec.category_id       := p_new_inv_category;
       p_task_template_search_rec.problem_code      := p_new_prob_code;
         --
         cs_autogen_task_pvt.get_task_template_group( p_api_version              => 1.0
                                                    , p_init_msg_list            => 'T'
                                                    , p_commit                   => fnd_api.g_false
                                                    , p_validation_level         => fnd_api.g_valid_level_full
                                                    , p_task_template_search_rec => p_task_template_search_rec
                                                    , x_task_template_group_tbl  => l_task_template_group_tbl
                                                    , x_return_status            => x_return_status
                                                    , x_msg_count                => x_msg_count
                                                    , x_msg_data                 => x_msg_data
                                                    );
         --
         if (x_return_status = fnd_api.g_ret_sts_error) then
           raise fnd_api.g_exc_error;
         elsif (x_return_status = fnd_api.g_ret_sts_unexp_error) then
           raise fnd_api.g_exc_unexpected_error;
         elsif (x_return_status = fnd_api.g_ret_sts_success) then
           --
           if l_task_template_group_tbl.count > 1 then
             --
             for i in l_task_template_group_tbl.first..l_task_template_group_tbl.last loop
               open c_task_temp_grp_name(l_task_template_group_tbl(i).task_template_group_id);
               fetch c_task_temp_grp_name into l_task_temp_grp_name;
               close c_task_temp_grp_name;
               --
               if l_task_temp_grp_names is not null then
                 l_task_temp_grp_names := l_task_temp_grp_names||', '||l_task_temp_grp_name;
               else
                 l_task_temp_grp_names := l_task_temp_grp_name;
               end if;
               --
             end loop;
             --
             if fnd_msg_pub.check_msg_level( fnd_msg_pub.g_msg_lvl_success ) then
               fnd_message.set_name('CS','CS_SR_MULTIPLE_TASK_TEMP_GRP');
               fnd_message.set_token('TGT_NAMES', l_task_temp_grp_names);
               fnd_msg_pub.add_detail(p_message_type => fnd_msg_pub.G_WARNING_MSG);
             end if;
           elsif l_task_template_group_tbl.count = 1 then
             l_new_task_group_template_id := l_task_template_group_tbl(0).task_template_group_id;
               for i in  c_task_template_id
               --
               loop
                 fetch c_task_template_id into l_old_task_group_template_id;
                 --
                 if(l_old_task_group_template_id = l_new_task_group_template_id) then
                   l_found_flag := 'Y';
                   exit;
                 end if;
                 --
               end loop;
               --
             if (l_found_flag = 'N') then
               open c_task_temp_grp_name(l_new_task_group_template_id);
               fetch c_task_temp_grp_name into l_task_temp_grp_name;
               close c_task_temp_grp_name;
               --
               if fnd_msg_pub.check_msg_level( fnd_msg_pub.g_msg_lvl_success ) then
                 fnd_message.set_name('CS', 'CS_SR_TASK_TEMP_GRP_MISMATCH');
                 fnd_message.set_token('TGT_NAME', l_task_temp_grp_name);
                 fnd_msg_pub.add_detail(p_message_type => fnd_msg_pub.G_WARNING_MSG);
               end if;
               --
             end if;
           end if;
           --
         end if;
         --
  end if;

  fnd_msg_pub.count_and_get
  ( p_count => x_msg_count
  , p_data  => x_msg_data
  );

--
exception
--
  when fnd_api.g_exc_error then
    --
    x_return_status := fnd_api.g_ret_sts_success;
    if fnd_msg_pub.check_msg_level( fnd_msg_pub.g_msg_lvl_success ) then
      fnd_message.set_name('CS', 'CS_SR_TASK_TEMP_GRP_API_ERROR');
      fnd_msg_pub.add_detail(p_message_type => fnd_msg_pub.G_WARNING_MSG);
    end if;
    --
    fnd_msg_pub.count_and_get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
  when fnd_api.g_exc_unexpected_error then
    --
    x_return_status := fnd_api.g_ret_sts_success;
    if fnd_msg_pub.check_msg_level( fnd_msg_pub.g_msg_lvl_success ) then
      fnd_message.set_name('CS', 'CS_SR_TASK_TEMP_GRP_API_ERROR');
      fnd_msg_pub.add_detail(p_message_type => fnd_msg_pub.G_WARNING_MSG);
    end if;
    --
    fnd_msg_pub.count_and_get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
  when others then
    --
    if c_task_template_id%isopen then
      close c_task_template_id;
    end if;
    --
    if c_task_temp_grp_name%isopen then
      close c_task_temp_grp_name;
    end if;
    --
    x_return_status := fnd_api.g_ret_sts_success;
    if fnd_msg_pub.check_msg_level( fnd_msg_pub.g_msg_lvl_success ) then
      fnd_message.set_name('CS', 'CS_SR_TASK_TEMP_GRP_API_ERROR');
      fnd_msg_pub.add_detail(p_message_type => fnd_msg_pub.G_WARNING_MSG);
    end if;
    --
    fnd_msg_pub.count_and_get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
--
end task_group_template_mismatch;
--
-- -------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : get_instance_details
--  Type        : Private
--  Description : gets the contact and contract given an instance, primarily
--                used for defaulting when instance is selected
-- -------------------------------------------------------------------------
procedure get_instance_details
( p_instance_id     in         number
, p_inc_type_id     in         number   default fnd_profile.value('INC_DEFAULT_INCIDENT_TYPE')
, p_severity_id     in         number   default fnd_profile.value('INC_DEFAULT_INCIDENT_SEVERITY')
, p_request_date    in         date     default sysdate
, p_timezone_id     in         number   default fnd_profile.value('SERVER_TIMEZONE_ID')
, p_get_contact     in         varchar2 default fnd_api.g_false
, x_contact_id      out nocopy number
, x_contact_type    out nocopy varchar2
, x_contract_id     out nocopy number
, x_contract_number out nocopy varchar2
, x_service_line_id out nocopy number
, x_coverage_term   out nocopy varchar2
, x_warranty_flag   out nocopy varchar2
, x_reaction_time   out nocopy date
, x_resolution_time out nocopy date
, x_service_desc    out nocopy varchar2
) is
--
  l_biz_process_id number;
  l_inp_rec        OKS_ENTITLEMENTS_PUB.GET_CONTIN_REC;
--
  l_party_id       number;
  x_ent_contracts  OKS_ENTITLEMENTS_PUB.GET_CONTOP_TBL;
  x_return_status  varchar2(2000);
  x_msg_count      number;
  x_msg_data       varchar2(2000);
--
  cursor c_biz_process is
  select
    business_process_id
  from
    cs_incident_types
  where
    incident_type_id = p_inc_type_id;
--
  cursor c_contact is
  select
    decode(contact.party_source_table, 'HZ_PARTIES', 'PARTY_RELATIONSHIP', 'EMPLOYEE') contact_type,
    contact.party_id contact_id,
    owner.party_id
  from
    csi_i_parties contact,
    csi_i_parties owner
  where
        contact.instance_id = p_instance_id
    and contact.contact_flag = 'Y'
    and contact.primary_flag = 'Y'
    and contact.contact_ip_id = owner.instance_party_id
    and owner.contact_flag = 'N'
    and owner.relationship_type_code = 'OWNER';
--
  cursor c_party_relation(l_object_id in number, l_subject_id in number) is
  select
    party_id
  from
    hz_relationships
  where
        object_id = l_object_id
    and subject_id = l_subject_id;
--
begin
--
  if p_get_contact = fnd_api.g_true then
  --
    for r_contact in c_contact
    --
    loop
      --
      x_contact_id   := r_contact.contact_id;
      x_contact_type := r_contact.contact_type;
      l_party_id     := r_contact.party_id;
      exit when c_contact%rowcount > 1;
      --
    end loop;
    --
    if x_contact_type = 'PARTY_RELATIONSHIP' then
    --
      for r_party_relation in c_party_relation(l_party_id, x_contact_id)
      --
      loop
        --
        x_contact_id := r_party_relation.party_id;
        exit when c_party_relation%rowcount > 1;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for r_biz_process in c_biz_process
  --
  loop
    --
    l_biz_process_id := r_biz_process.business_process_id;
    exit when c_biz_process%rowcount > 1;
    --
  end loop;
  --
  l_inp_rec.request_date        := p_request_date;
  l_inp_rec.business_process_id := l_biz_process_id;
  l_inp_rec.severity_id         := p_severity_id;
  l_inp_rec.time_zone_id        := p_timezone_id;
  l_inp_rec.product_id          := p_instance_id;
  l_inp_rec.calc_resptime_flag  := 'Y';
  l_inp_rec.validate_flag       := 'Y';
  l_inp_rec.sort_key            := '';
  --
  oks_entitlements_pub.get_contracts
  ( 1.0
  , 'T'
  , l_inp_rec
  , x_return_status
  , x_msg_count
  , x_msg_data
  , x_ent_contracts
  );
  --
  if x_return_status = fnd_api.g_ret_sts_success then
    --
    if x_ent_contracts.count > 0 then
      x_contract_id      := x_ent_contracts(1).contract_id;
      x_contract_number  := x_ent_contracts(1).contract_number;
      x_service_line_id  := x_ent_contracts(1).service_line_id;
      x_coverage_term    := x_ent_contracts(1).coverage_term_name;
      x_warranty_flag    := x_ent_contracts(1).warranty_flag;
      x_reaction_time    := x_ent_contracts(1).exp_reaction_time;
      x_resolution_time  := x_ent_contracts(1).exp_resolution_time;
      --
      if x_ent_contracts(1).contract_number_modifier is not null then
        x_service_desc := x_ent_contracts(1).contract_number||' - '||
                          x_ent_contracts(1).contract_number_modifier||' : '||
                          x_ent_contracts(1).service_name;
      else
        x_service_desc := x_ent_contracts(1).contract_number||' : '||
                          x_ent_contracts(1).service_name;
      end if;
      --
    end if;
    --
  else
    raise fnd_api.g_exc_error;
  end if;
  --
--
exception
--
  when fnd_api.g_exc_error then
    null;
--
  when others then
    --
    if c_biz_process%isopen then
      close c_biz_process;
    end if;
    --
    if c_contact%isopen then
      close c_contact;
    end if;
    --
    if c_party_relation%isopen then
      close c_party_relation;
    end if;
    --
end get_instance_details;
--
-- -------------------------------------------------------------------------
--
-- -------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : get_linked_srs
--  Type        : Private
--  Description : get linked srs linked as duplicateof, causedby, refersto
--                (used to display linked srs in KM Unified sr search)
-- -------------------------------------------------------------------------
   FUNCTION get_linked_srs (p_incident_id IN NUMBER) RETURN VARCHAR2
   AS
     CURSOR l_linked_cursor (l_incident_id in NUMBER) IS
      select  SrLnkEO.link_id link_id
      , SrLnkEO.object_type object_type
      , SrLnkEO.object_id object_id
      , SrLnkEO.object_number object_number
      , SrLnkEO.subject_id subject_id
      , SrLnkEO.subject_type subject_type
      , SrLnkEO.link_type_id link_type_id
      , ltype.name link_type_name
      from cs_incident_links SrLnkEO,
           cs_incidents_all_b  sr,
           cs_sr_link_types_vl ltype
      where SrLnkEO.object_id = sr.incident_id
      and SrLnkEO.subject_type = 'SR'
      and SrLnkEO.object_type = 'SR'
      and sysdate between
      nvl(SrLnkEO.start_date_active,sysdate)
      and nvl(SrLnkEO.end_date_active,sysdate)
      and SrLnkEO.link_type_id = ltype.link_type_id
      and SrLnkEO.subject_id = l_incident_id
      and ltype.link_type_id in (2, 3, 6);
      linked_sr_rec l_linked_cursor%ROWTYPE;
      l_linked_sr_str VARCHAR2(1000) := '';
   BEGIN
      for l_linked_rec in l_linked_cursor (p_incident_id) loop
         l_linked_sr_str := l_linked_sr_str ||' ' || l_linked_rec.link_type_name || ' ' || l_linked_rec.object_number;
      end loop;
      return l_linked_sr_str;
   EXCEPTION
      WHEN OTHERS THEN
          if l_linked_cursor%isopen
          then
            close l_linked_cursor;
          end if;
   END;

-- -------------------------------------------------------------------------
-- Start of comments
-- UTIL Name   : get_contact_info
-- Type        : Private
-- Description : To get the Contact info based on the Incident id, ContactPartyId,PartyId and ContactType, primarycontact
-- Parameters  :
-- IN:  p_incident_id IN  VARCHAR2  Required
-- IN:  p_contact_type IN  VARCHAR2
-- IN : p_contact_party_id     IN  NUMBER
-- IN : p_party_id     IN  NUMBER Required
-- IN : p_primary_contact     IN  NUMBER Required
-- Returnvalue:
-- l_contact_name  VARCHAR2(360)
-- End of comments
-- -------------------------------------------------------------------------
FUNCTION get_contact_info
( p_incident_id IN NUMBER
 ,p_contact_type IN VARCHAR2
 ,p_contact_party_id IN NUMBER
 ,p_party_id  IN NUMBER
 ,p_primary_contact IN VARCHAR2
) RETURN VARCHAR2 AS
 l_contact_party_id NUMBER;
 l_contact_type VARCHAR2(400) default null;
 l_contact_name VARCHAR2(4000) default null;
 cursor cont(param_incident_id NUMBER,param_primary_flag VARCHAR2) is
 select contact_type, party_id
 from cs_hz_sr_contact_points
 where incident_id = param_incident_id and primary_flag = param_primary_flag and
 rownum < 2   order by party_id;
begin
  -- If contact partyid is absent then find the contact based on incident info
  if (p_contact_party_id is null) then
     OPEN cont(p_incident_id,p_primary_contact);
       fetch cont into l_contact_type, l_contact_party_id;
       if cont%notfound then
          l_contact_type := '';
          l_contact_party_id := 0;
       end if;
     close cont;
  else
  -- Else find the contact based on provided contact information
     l_contact_type := p_contact_type;
     l_contact_party_id := p_contact_party_id;
  end if;
  return get_contact_name (l_contact_type, l_contact_party_id, p_party_id);
end;
--
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : GET_TIMEZONE_FOR_CONTACT
--  Type        : Private
--  Description : Returns the Timezone Id for a Contact/ContactPoint/Location.
-- Logic : In case if the contact type is Employee return Null;
--  If contact point Id is passed, query the timezone for the contact point.
--  If either the contact point Id is null or if the timezone associated with the
--  Contact point is null , then query the Primary location for the contact and get
--  the timezone associated with the primary location from HZ_CONTACTS
--  Parameters  :
--  IN :  p_contact_type      IN VARCHAR2   Optional. If not passed assumed not an Employee
--  IN :  p_contact_point_id  IN Number  Optional
--  IN :  p_contact_id        IN Number  Optional
--  ReturnValue:
-- l_timezone_id  NUMBER

--    Control comes here only when contact type != EMPLOYEE
--    if the contact_type is PARTY_RELATIONSHIP OR PERSON
-- --------------------------------------------------------------------------------

Function     GET_TIMEZONE_FOR_LOCATION
(p_contact_id  IN NUMBER)
  RETURN  NUMBER
  AS
       l_timezone_id NUMBER DEFAULT NULL;
  BEGIN
	if p_contact_id is not null and p_contact_id <> -1 then
		SELECT	timezone_id
		INTO	l_timezone_id
		FROM	hz_locations
		WHERE	location_id = (	SELECT	location_id
				FROM	hz_party_sites
				WHERE	party_id = p_contact_id
				AND	identifying_address_flag = 'Y'
				AND	status = 'A' ) ;
	end if;
	return l_timezone_id;
  EXCEPTION
	when others then
		return null;
  END;


FUNCTION     GET_TIMEZONE_FOR_CONTACT
( p_contact_type  IN VARCHAR2,
  p_contact_id  IN NUMBER,
  p_contact_point_id  IN NUMBER
) RETURN VARCHAR2
  AS
   l_timezone_id NUMBER DEFAULT NULL;
   l_timezone_name VARCHAR2(80) DEFAULT NULL;
   l_timezone_code VARCHAR2(50) DEFAULT NULL;
  BEGIN

  if p_contact_type = 'EMPLOYEE' then
     return null;
  end if;

  if p_contact_point_id is not null  then
	 SELECT  timezone_id
	 INTO	 l_timezone_id
	 FROM    hz_contact_points
         WHERE   contact_point_id  =  p_contact_point_id
	 AND	 status = 'A' ;
	 if l_timezone_id is not null then
		SELECT	name ,
			timezone_code
		INTO	l_timezone_name,
			l_timezone_code
		FROM	FND_TIMEZONES_VL
		WHERE	UPGRADE_TZ_ID = l_timezone_id
		AND	ENABLED_FLAG = 'Y';

		return l_timezone_id || '::' || l_timezone_name || '::' || l_timezone_code;
	 end if;
  end if;

  l_timezone_id :=  GET_TIMEZONE_FOR_LOCATION(p_contact_id);
  -- Timezone name is also queried and Concatenated with a hyphen
  if l_timezone_id is not null then
	SELECT	name ,
		timezone_code
	INTO	l_timezone_name,
		l_timezone_code
	FROM	FND_TIMEZONES_VL
	WHERE	UPGRADE_TZ_ID = l_timezone_id
	AND	ENABLED_FLAG = 'Y';
  end if;
  return l_timezone_id || '::' || l_timezone_name || '::' || l_timezone_code;

  EXCEPTION
	when others then
		return null;
  END;

--
-- --------------------------------------------------------------------------------

-- Start of comments
-- UTIL Name   : GET_FIRST_NOTE
-- Type        : Private
-- Description : Given a INCIDENT_ID this function will return the recently
---                 added note to the service request number.
-- Parameters  :
-- IN : p_incident_id NUMBER Required
-- OUT: Returns l_first_note  VARCHAR2(2000)
-- End of comments
-- -------------------------------------------------------------------------
Function      GET_FIRST_NOTE
  ( p_incident_id IN NUMBER)
  RETURN  VARCHAR2 IS
   l_first_note  varchar2(2000) DEFAULT NULL;
     CURSOR c_first_note(param_incident_id NUMBER) is
      select  notes
      from    jtf_notes_vl
      where   source_object_code = 'SR' and  source_object_id =param_incident_id
       order by  creation_date;
begin
  open c_first_note (p_incident_id);
      fetch c_first_note into l_first_note;
  close c_first_note;
  RETURN l_first_note ;

EXCEPTION
   WHEN OTHERS THEN
    IF c_first_note%ISOPEN THEN
      CLOSE c_first_note;
    END IF;
   return null;
end GET_FIRST_NOTE;
-- -------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : CHECK_IF_NEXT_WORK_ENABLED
--  Type        : Private
--  Description : Calls the
--                 IEU_WR_PUB. CHECK_WS_ACTIVATION_STATUS
--                 to verify if the activation flag is turned on
--                  for the worksource code
-- Parameters  :
-- IN  : p_ws_code              VARCHAR2  Required
-- OUT : x_enable_next_work     NUMBER
-- OUT : x_msg_count            NUMBER
-- OUT : x_return_status        VARCHAR2
-- OUT : x_msg_data             VARCHAR2
-- End of comments
-- ------------------------------------------------------------------------------------
      PROCEDURE CHECK_IF_NEXT_WORK_ENABLED
     ( p_ws_code               IN VARCHAR2,
       x_enable_next_work         OUT nocopy VARCHAR2,
	   x_msg_count                OUT nocopy NUMBER,
 	   x_return_status            OUT nocopy VARCHAR2,
	   x_msg_data                 OUT nocopy VARCHAR2) IS

    BEGIN

        BEGIN
  -- Invoke the IEU API to get the Activation status of work source

	IEU_WR_PUB.CHECK_WS_ACTIVATION_STATUS
	( p_api_version              => 1,
	  p_ws_code                  =>p_ws_code,
	  x_ws_activation_status     =>x_enable_next_work,
      x_msg_count                => x_msg_count,
	  x_msg_data                 => x_msg_data,
	  x_return_status            => x_return_status);

 EXCEPTION
    WHEN OTHERS THEN
        fnd_msg_pub.Count_and_Get
	          (
	              p_count   =>   x_msg_count,
	             p_data    =>   x_msg_data
              );
        RAISE fnd_api.g_exc_error;
  END;


Exception

	 WHEN fnd_api.g_exc_error THEN
	  x_return_status := 'E';
	  fnd_msg_pub.Count_and_Get
	  (
	    p_count   =>   x_msg_count,
	    p_data    =>   x_msg_data
	  );

	 WHEN fnd_api.g_exc_unexpected_error THEN
	  x_return_status := 'U';
	  fnd_msg_pub.Count_and_Get
	  (
	    p_count   =>   x_msg_count,
	    p_data    =>   x_msg_data
	  );

   END CHECK_IF_NEXT_WORK_ENABLED;
-- ------------------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : GET_NEXT_SR_TO_WORK
--  Type        : Private
--  Description : Calls  IEU_WR_PUB.GET_NEXT_WORK_FOR_APPS
--                and returns the incident_id retreived from the above call.
-- Parameters  :
-- IN  : p_ws_code              VARCHAR2  Required
-- IN  : p_resource_id          NUMBER  Required
-- OUT : x_incident_id          NUMBER
-- OUT : x_msg_count            NUMBER
-- OUT : x_return_status        VARCHAR2
-- OUT : x_msg_data             VARCHAR2
-- End of comments

-- ------------------------------------------------------------------------------------
  PROCEDURE GET_NEXT_SR_TO_WORK
       ( p_ws_code               IN VARCHAR2,
         p_resource_id           IN NUMBER,
         x_incident_id           OUT nocopy NUMBER,
         x_msg_count             OUT nocopy NUMBER,
         x_return_status         OUT nocopy VARCHAR2,
         x_msg_data              OUT nocopy VARCHAR2,
         x_object_type           OUT nocopy VARCHAR2) IS

 --declare variables
         l_ws_det_list   IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WS_DETAILS_LIST;
         l_uwqm_workitem_data  IEU_FRM_PVT.T_IEU_MEDIA_DATA;
         l_language               VARCHAR2(10);
         l_source_lang            VARCHAR2(10);
         j number;
         x_enable_next_work       VARCHAR2(10);
         x_distribute_sr_task     VARCHAR2(10);
   BEGIN
       l_ws_det_list(1).ws_code := p_ws_code;
       l_language := userenv('lang');
 		l_source_lang  := 'US';
       j :=0;

   BEGIN
   -- Check if SR-TASK worksource is enabled
   CHECK_IF_NEXT_WORK_ENABLED
      ( p_ws_code           => 'SR_TASKS',
        x_enable_next_work =>x_enable_next_work ,
 	   x_msg_count   => x_msg_count     ,
  	   x_return_status => x_return_status   ,
 	   x_msg_data=> x_msg_data);

   -- Check if IEU: Distribute: Service Request Task: Work Source




   -- profile is enabled
   fnd_profile.get('IEU_WR_DIS_SR_TASKS_WS', x_distribute_sr_task);

   -- If SR_TASK is enabled, pass SR-TASK also as object code
   If( (x_enable_next_work = 'Y') AND (x_distribute_sr_task = 'Y')) THEN
       l_ws_det_list(2).ws_code := 'SR_TASKS';
   END IF;

   -- Invoke the IEU API to get the incident Id
   IEU_WR_PUB.GET_NEXT_WORK_FOR_APPS
       ( p_api_version                  => 1,
 	     p_resource_id                  => p_resource_id,
 	     p_language                     => l_language,
 	     p_source_lang                  => l_source_lang,
         p_ws_det_list                  => l_ws_det_list,
 	     x_uwqm_workitem_data           => l_uwqm_workitem_data,
 	     x_msg_count                    => x_msg_count,
 	     x_msg_data                     => x_msg_data,
 	     x_return_status                => x_return_status);

  EXCEPTION
     WHEN OTHERS THEN
         fnd_msg_pub.Count_and_Get
 	          (
 	              p_count   =>   x_msg_count,
 	             p_data    =>   x_msg_data
               );
         RAISE fnd_api.g_exc_error;
   END;

  -- If the return status is Success or if the OUT param l_uwqm_workitem_data
  -- has values. Then retrieve the first row and get the incident_id
  -- which in the WORKITEM_PK_ID

  if (x_return_status = 'S') OR (l_uwqm_workitem_data.count >= 1)
   then

  FOR j in l_uwqm_workitem_data.first .. l_uwqm_workitem_data.last
   LOOP

          if (l_uwqm_workitem_data(j).param_name = 'WORKITEM_PK_ID')
          then
              x_incident_id := l_uwqm_workitem_data(j).param_value;
          end if;
          if ( l_uwqm_workitem_data(j).param_name = 'WORKITEM_OBJ_CODE')
          then
              x_object_type := l_uwqm_workitem_data(j).param_value;
          end if;

          if( x_incident_id <> NULL) AND (x_object_type <> NULL) then
          exit;
          end if;
 end loop;
   end if;

 Exception

 	 WHEN fnd_api.g_exc_error THEN
 	  x_return_status := 'E';
 	  fnd_msg_pub.Count_and_Get
 	  (
 	    p_count   =>   x_msg_count,
 	    p_data    =>   x_msg_data
 	  );

 	 WHEN fnd_api.g_exc_unexpected_error THEN
 	  x_return_status := 'U';
 	  fnd_msg_pub.Count_and_Get
 	  (
 	    p_count   =>   x_msg_count,
 	    p_data    =>   x_msg_data
 	  );

END GET_NEXT_SR_TO_WORK;

-- -------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : GET_SR_ESCALATED
--  Type        : Private
--  Description : Returns Y if Service Request is escalated, else returns N
--  Parameters  :
--  IN : p_incident_id    IN  NUMBER Required
--
--- Returnvalue:
--  l_sr_escalated  VARCHAR2(1)
-- End of comments
-- --------------------------------------------------------------------------
Function      GET_SR_ESCALATED
  (  p_incident_id       IN NUMBER
  )
  RETURN  VARCHAR2 IS
   l_object_id     NUMBER;
   cursor c_escal_id(param_incident_id NUMBER) is
   select trf.object_id
     from jtf_tasks_b tsk,
          jtf_task_references_b trf
    where tsk.task_id = trf.task_id
      and tsk.task_type_id = 22
      and tsk.escalation_level not in ('DE', 'NE')
      and nvl(tsk.open_flag, 'Y') = 'Y'
      and trf.reference_code = 'ESC'
      and trf.object_type_code = 'SR'
      and trf.object_id = param_incident_id;
BEGIN
  open c_escal_id (p_incident_id);
  fetch c_escal_id into l_object_id;
  close c_escal_id;

  if l_object_id is not null then
    return 'Y';  --if found escalated
  end if;
  return 'N';  --if not found
EXCEPTION
   WHEN OTHERS THEN
    IF c_escal_id%ISOPEN THEN
      CLOSE c_escal_id;
    END IF;
END GET_SR_ESCALATED;
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : GET_CONTACT_NAME
--  Type        : Private
--  Description : Returns contact name
--  Parameters  :
--  IN : p_incident_id    IN  NUMBER
--       p_customer_id    IN  NUMBER
--  Returnvalue: contact name
--
--  (If we make this api get_contact_info, it can return
--   <contact number>-separator<contact name>separator<phone>separator<email>)
-- End of comments
-- -------------------------------------------------------------------------

Function      GET_CONTACT_NAME
  (  p_incident_id       IN NUMBER,
     p_customer_id       IN NUMBER
     --,p_separator         IN VARCHAR --needed for get_contact_info api
  )
RETURN  VARCHAR2 IS
   l_return_val     VARCHAR2(255);
   l_contact_party_id number;
   l_contact_type varchar2(30);
   l_effective_start_date DATE DEFAULT NULL;
   l_effective_end_date DATE DEFAULT NULL;

   --l_contact_num varchar2(30);
   l_contact_name varchar2(360); --emp.fullname 240,party_name 360
   --l_contact_phone varchar2(83); --emp 60, party phone and space 83
   --l_contact_email varchar2(2000); --emp 240, party 2000


  cursor c_sr_cont is
   select sr_cont.party_id,
          sr_cont.contact_type
   from cs_hz_sr_contact_points sr_cont
   where sr_cont.incident_id = p_incident_id
     and sr_cont.primary_flag = 'Y';

  cursor c_emp(param_party_contact_id NUMBER) is
    select --employee_number,
           full_name,
           --, work_telephone, email_address,
           effective_start_date,effective_end_date
    from per_all_people_f
    where person_id = param_party_contact_id
    order by effective_start_date desc;

  cursor c_party is
    select --hz.party_number,
           hz.party_name
             --,hz.primary_phone_country_code||' '||
             --hz.primary_phone_area_code||' '||
             --hz.primary_phone_number||' '||
             --hz.primary_phone_extension,
             --hz.email_address
    from hz_parties hz
    where hz.party_id = p_customer_id;

  cursor c_rel(param_contact_party_id NUMBER) is
    select --hz.party_number,
           hz.party_name
             --,hz.primary_phone_country_code||' '||
             --hz.primary_phone_area_code||' '||
             --hz.primary_phone_number||' '||
             --hz.primary_phone_extension,
             --hz.email_address
    from hz_parties hz, hz_relationships rel
    where  rel.party_id = param_contact_party_id
    and  rel.object_id = p_customer_id
    and rel.subject_id = hz.party_id
    and rel.subject_type = 'PERSON';
BEGIN

  open c_sr_cont;
  fetch c_sr_cont into l_contact_party_id, l_contact_type;
  close c_sr_cont;

  if l_contact_type = 'PERSON' then
    open c_party;
    fetch c_party into l_contact_name;
      --l_contact_num, l_contact_name, l_contact_phone, l_contact_email;
    close c_party;

  elsif l_contact_type = 'PARTY_RELATIONSHIP' then
    open c_rel(l_contact_party_id);
    fetch c_rel into l_contact_name;
      --l_contact_num, l_contact_name, l_contact_phone, l_contact_email;
    close c_rel;

  elsif l_contact_type = 'EMPLOYEE' then
      OPEN c_emp(l_contact_party_id);
      FETCH c_emp into l_contact_name,
        --l_contact_num, l_contact_name, l_contact_phone, l_contact_email
        l_effective_start_date,l_effective_end_date;
      CLOSE c_emp;
  else
     return null;
  end if;

  /*if l_contact_name is not null then
    return l_contact_num||p_separator||
           l_contact_name||p_separator||
           l_contact_phone||p_separator||
           l_contact_email;
  end if;*/

  return l_contact_name;


EXCEPTION
   WHEN OTHERS THEN
    IF c_sr_cont%ISOPEN THEN
      CLOSE c_sr_cont;
    END IF;
    IF c_emp%ISOPEN THEN
      CLOSE c_emp;
    END IF;
    IF c_party%ISOPEN THEN
      CLOSE c_party;
    END IF;
    IF c_rel%ISOPEN THEN
      CLOSE c_rel;
    END IF;
END GET_CONTACT_NAME;

-- -------------------------------------------------------------------------
FUNCTION GET_REL_OBJ_DETAILS
  (  p_object_type       IN VARCHAR2,
     p_object_id       IN NUMBER
  )
RETURN  VARCHAR2
IS
   CURSOR c_jtf_object
   (p_object_type IN VARCHAR2
   )IS SELECT  select_id,
               select_details ,
               from_table ,
               where_clause
       FROM jtf_objects_b
       WHERE select_id is not null
         and select_details is not null
         and from_table is not null
         AND object_code = p_object_type;

  l_select_id        jtf_objects_b.select_id%TYPE;
  l_select_details   jtf_objects_b.select_details%TYPE;
  l_from_table       jtf_objects_b.from_table%TYPE;
  l_where_clause     jtf_objects_b.where_clause%TYPE;
  l_sql_statement    VARCHAR2(3000);
  l_details          VARCHAR2(5000);
  l_select_id_alias  jtf_objects_b.select_id%TYPE;
  l_select_id_value  NUMBER;
  position           NUMBER;

  type details_type is REF CURSOR;
  details_cursor details_type;

BEGIN
  IF c_jtf_object%ISOPEN
  THEN
      CLOSE c_jtf_object;
  END IF;

  OPEN c_jtf_object(p_object_type);
  FETCH c_jtf_object INTO l_select_id,
                          l_select_details,
                          l_from_table,
                          l_where_clause;
  IF c_jtf_object%ROWCOUNT = 0 THEN
    RETURN NULL;
  END IF;
  CLOSE c_jtf_object;

  --contruct the sql statement for this object type
  l_sql_statement := 'SELECT ' || l_select_details || ', ' || l_select_id
                     || ' FROM ' || l_from_table;
  if l_where_clause is not null then
    l_sql_statement := l_sql_statement || ' WHERE '|| l_where_clause;
  end if;

  position := instr(l_select_id, ' ', -1, 1);
  l_select_id_alias := substr(l_select_id, position+1);

  if position <> 0 then
    l_sql_statement := 'SELECT * FROM (' ||
                       l_sql_statement ||
                       ' ) ' ||
                       ' WHERE ' ||
                       l_select_id_alias || ' = :select_id';

  else
    if l_where_clause is null then
       l_sql_statement := l_sql_statement
                          || ' WHERE '
                          || l_select_id || ' = :select_id';
    else
       l_sql_statement := l_sql_statement
                          || ' AND '
                          || l_select_id || ' = :select_id';
    end if;
  end if;

  open details_cursor for l_sql_statement using p_object_id;
  fetch details_cursor into l_details, l_select_id_value;
  if details_cursor%NOTFOUND then
	    null;    -- Hardcode
  end if;
  close details_cursor;

  return l_details;
END GET_REL_OBJ_DETAILS;

-- -------------------------------------------------------------------------
-- Start of comments
-- UTIL Name   : get_assc_party_name
-- Type        : Private
-- Description : To get the AsscPartyname based on AsscPartyId,AsscPartyType
-- Parameters  :
-- IN:  p_assc_party_type IN  VARCHAR2
-- IN : p_assc_party_id     IN  NUMBER
-- Returnvalue:
-- l_assc_party_name  VARCHAR2(360)
-- End of comments
-- -------------------------------------------------------------------------
FUNCTION get_assc_party_name
( p_assc_party_type IN VARCHAR2
 ,p_assc_party_id  IN  NUMBER
) RETURN VARCHAR2 as
--
  l_assc_party_name varchar2(360) DEFAULT NULL;
  l_employee_name varchar2(360) DEFAULT NULL;
  l_effective_start_date DATE DEFAULT NULL;
  l_effective_end_date DATE DEFAULT NULL;
--
  cursor c1(param_person_id NUMBER) is
  select full_name,effective_start_date,effective_end_date
  from per_all_people_f
  where person_id = param_person_id
  order by effective_start_date desc;
--
begin
--
  if p_assc_party_type = 'PERSON' or  p_assc_party_type ='PARTY_RELATIONSHIP' OR
      p_assc_party_type ='ORGANIZATION' then
    select hz.party_name
    into l_assc_party_name
    from hz_parties hz
    where hz.party_id = p_assc_party_id;
 elsif p_assc_party_type = 'EMPLOYEE' then
      OPEN c1(p_assc_party_id);
         LOOP
          FETCH c1 into
         l_employee_name,l_effective_start_date,l_effective_end_date;
          EXIT WHEN c1%NOTFOUND;
           if (l_effective_start_date is not null and l_employee_name is not
null) then
               l_assc_party_name := l_employee_name;
             EXIT;
          end if;
         END LOOP;
      CLOSE c1;
  else
     return null;
  end if;
  return l_assc_party_name;
end;
-- -------------------------------------------------------------------------
-- Start of comments
-- UTIL Name   : get_concat_associated_role
-- Type        : Private
-- Description : To get associated party roles for incident_id
-- Parameters  :
-- IN : p_incident_id     IN  NUMBER
-- IN : p_party_id     IN  NUMBER
-- IN : p_party_type     IN  VARCHAR2
-- Returnvalue:
-- l_assc_party_role_names VARCHAR2(360)
-- End of comments
FUNCTION get_concat_associated_role(
  p_incident_id  IN  NUMBER
 ,p_party_id IN NUMBER
 ,p_party_type IN VARCHAR2)
RETURN VARCHAR2 as
 l_part_role_name varchar2(360) DEFAULT NULL;
 l_concat_party_role_names varchar2(360) DEFAULT NULL;
-- Person cursor
cursor personCursor(p_incident_id NUMBER, p_party_id NUMBER) is
select distinct partyrole.name
from cs_hz_sr_contact_points cp, CS_PARTY_ROLES_VL partyrole
where cp.party_role_code = partyrole.party_role_code
and cp.incident_id = p_incident_id
and
(
(cp.contact_type = 'PERSON'
    and cp.party_id = p_party_id)
or
(cp.contact_type = 'PARTY_RELATIONSHIP'
     and cp.party_id in ( select party_id
                          from hz_relationships
                          where subject_id = p_party_id
                          and subject_type = 'PERSON')
 )
);

-- Organization cursor
cursor OrgEmpRelationshipCursor(p_incident_id NUMBER,
                          p_party_id NUMBER,
                          p_party_type VARCHAR2) is
select distinct partyrole.name
from cs_hz_sr_contact_points cp, CS_PARTY_ROLES_VL partyrole
where cp.party_role_code = partyrole.party_role_code
and cp.incident_id = p_incident_id
and
(
    cp.contact_type = p_party_type
    and cp.party_id = p_party_id
);
begin
-- For a particular case Id write a cursor to get all the roles for the party
-- Get the roles from the cursor and concatenated to the varchar and return back the final string.
if p_party_type = 'PERSON' then
      OPEN PersonCursor(p_incident_id, p_party_id);
         LOOP
          FETCH PersonCursor into l_part_role_name;
          EXIT WHEN PersonCursor%NOTFOUND;
           if ( l_part_role_name is not null) then
               if (l_concat_party_role_names is not null) then
                   l_concat_party_role_names := l_concat_party_role_names || ',' || l_part_role_name ;
               else
                   l_concat_party_role_names := l_part_role_name ;
               end if;
          end if;
         END LOOP;
      CLOSE PersonCursor;
else
      OPEN OrgEmpRelationshipCursor(p_incident_id, p_party_id, p_party_type);
         LOOP
          FETCH OrgEmpRelationshipCursor into l_part_role_name;
          EXIT WHEN OrgEmpRelationshipCursor%NOTFOUND;
           if ( l_part_role_name is not null) then
               if (l_concat_party_role_names is not null) then
                   l_concat_party_role_names := l_concat_party_role_names || ',' || l_part_role_name ;
               else
                   l_concat_party_role_names := l_part_role_name ;
               end if;
          end if;
         END LOOP;
      CLOSE OrgEmpRelationshipCursor;
end if;
return l_concat_party_role_names;
end;
-- -------------------------------------------------------------------------
-- Start of comments
-- UTIL Name   : get_emp_contact_name
-- Type        : Private
-- Description : To get the emp contact name based on the party id
-- Parameters  :
-- IN : p_person_id     IN  NUMBER
-- Returnvalue:
-- l_emp_contact_name  VARCHAR2(360)
-- End of comments
-- -------------------------------------------------------------------------
FUNCTION get_emp_contact_name
(p_person_id  IN  NUMBER
) RETURN VARCHAR2 as

 cursor get_emp_name is
 SELECT first_name || ' ' ||last_name
 FROM per_workforce_x
 WHERE person_id = p_person_id;

 l_emp_contact_name varchar2(360);

 begin
 l_emp_contact_name := null;
 open get_emp_name;
 fetch get_emp_name into l_emp_contact_name;
 close get_emp_name;

 return l_emp_contact_name;
end;
-- -------------------------------------------------------------------------
-- Start of comments
-- UTIL Name   : get_emp_contact_email
-- Type        : Private
-- Description : To get the emp contact email based on the person id
-- Parameters  :
-- IN : p_person_id     IN  NUMBER
-- Returnvalue:
-- l_emp_contact_email  VARCHAR2(250)
-- End of comments
-- -------------------------------------------------------------------------
FUNCTION get_emp_contact_email
(p_person_id  IN  NUMBER
) RETURN VARCHAR2 as

 cursor get_emp_email is
 SELECT email_address
 FROM per_workforce_x
 WHERE person_id = p_person_id;

 l_emp_contact_email varchar2(250);

begin
 l_emp_contact_email := null;
 open get_emp_email;
 fetch get_emp_email into l_emp_contact_email;
 close get_emp_email;

 return l_emp_contact_email;
end;

end csz_servicerequest_util_pvt;

/
