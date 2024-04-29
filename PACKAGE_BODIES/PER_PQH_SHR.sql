--------------------------------------------------------
--  DDL for Package Body PER_PQH_SHR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PQH_SHR" as
/* $Header: pepqhshr.pkb 120.3.12010000.2 2009/10/01 08:32:17 sathkris ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_pqh_shr.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< position_control_enabled >----------------------|
-- ----------------------------------------------------------------------------
function POSITION_CONTROL_ENABLED(P_ORGANIZATION_ID NUMBER default null,
                                  p_effective_date in date default sysdate,
                                  p_assignment_id number default null) RETURN VARCHAR2 IS
--
l_business_group_id number;
l_org_structure_version_id number;
l_organization_id   number;
l_pc_flag varchar2(10);
l_effective_date date := nvl(p_effective_date, sysdate);
--
cursor c2(p_business_group_id number, p_effective_date date) is
select ver.org_structure_version_id
from
	per_org_structure_versions ver,
	per_organization_structures str
where
	ver.organization_structure_id = str.organization_structure_id
    and str.business_group_id = p_business_group_id
	and str.position_control_structure_flg='Y'
	and nvl(p_effective_date, sysdate) between ver.date_from
	and nvl(ver.date_to, hr_general.end_of_time);
--
--
cursor c_assignment(p_assignment_id number, p_effective_date date) is
select organization_id, business_group_id
from
	per_all_assignments_f
where
	assignment_id = p_assignment_id
	and p_effective_date between effective_start_date and effective_end_date;
--
cursor c_organization(p_organization_id number) is
select business_group_id
from
    hr_all_organization_units
where
    organization_id = p_organization_id;
--
BEGIN
if p_organization_id is not null then
  l_organization_id := p_organization_id;
  open c_organization(p_organization_id);
  fetch c_organization into l_business_group_id;
  close c_organization;
elsif p_assignment_id is not null then
  open c_assignment(p_assignment_id, l_effective_date);
  fetch c_assignment into l_organization_id, l_business_group_id;
  close c_assignment;
end if;
--
if l_organization_id is not null then
  open c2(l_business_group_id, l_effective_date);
  fetch c2 into l_org_structure_version_id;
  close c2;
  --
  l_pc_flag := per_pqh_shr.POSITION_CONTROL_ENABLED(
                                  p_org_structure_version_id => l_org_structure_version_id,
                                  p_organization_id => l_organization_id,
                                  p_business_group_id => l_business_group_id);
  return l_pc_flag;
end if;
RETURN 'N';
END;
--
--
--  ---------------------------------------------------------------------------
--  |------------------------<   open_status    >-----------------------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Retrieves the funded_status of the position.
--
function open_status
         (p_position_id       in number, p_effective_date in date) return varchar2 is
  l_proc                varchar2(72) := g_package||'open_status';
  l_open_state 		varchar2(100):= 'OPEN';
begin
    hr_utility.set_location('Entering:'||l_proc, 5);
    --
    -- fetch open state
    --
    l_open_state := pqh_psf_bus.open_status(p_position_id, p_effective_date);
    --
    hr_utility.set_location(' Leaving:'||l_proc, 10);
    --
    return l_open_state;
end;
--
--  ---------------------------------------------------------------------------
--  |------------------------<   future approved actions    >-----------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Retrieves the future approved actions of the position.
--
function future_approved_actions
         (p_position_id       in number) return varchar2 is
  l_proc                varchar2(72) := g_package||'future_approved_actions';
  l_pending_action_flag	varchar2(100):= 'N';
begin
    hr_utility.set_location('Entering:'||l_proc, 5);
    --
    -- fetch future approved actions flag
    --
    l_pending_action_flag := pqh_psf_bus.future_approved_actions(p_position_id);
    --
    hr_utility.set_location(' Leaving:'||l_proc, 10);
    --
    return l_pending_action_flag;
end;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------<   per_abv_insert_validate    >-------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE per_abv_insert_validate(
		p_assignment_id number,
		p_value number,
		p_unit varchar2,
		p_effective_date date) is
--
  l_proc 	varchar2(72) := g_package||'per_abv_insert_validate';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
	pqh_psf_bus.per_abv_insert_validate(
		p_assignment_id 	=>p_assignment_id,
		p_value 		=>p_value,
		p_unit 			=>p_unit,
		p_effective_date 	=>p_effective_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end;
--
--  ---------------------------------------------------------------------------
--  |----------------------<   per_abv_update_validate    >-------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE per_abv_update_validate(
		p_abv_id number,
		p_assignment_id number,
		p_value number,
		p_unit varchar2,
		p_effective_date date,
		p_validation_start_date date,
		p_validation_end_date  date,
		p_datetrack_mode    varchar2) is
--
  l_proc 	varchar2(72) := g_package||'per_abv_update_validate';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
	pqh_psf_bus.per_abv_update_validate(
		p_abv_id 		=>p_abv_id,
		p_assignment_id 	=>p_assignment_id,
		p_value 		=>p_value,
		p_unit 			=>p_unit,
		p_effective_date 	=>p_effective_date,
		p_validation_start_date =>p_validation_start_date,
		p_validation_end_date  	=>p_validation_end_date,
		p_datetrack_mode    	=>p_datetrack_mode);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end;
--
-- ----------------------------------------------------------------------------
-- |------------------------< hr_psf_bus >--------------------|
-- ----------------------------------------------------------------------------
--
Procedure hr_psf_bus(p_event varchar2, p_rec  hr_psf_shd.g_rec_type
, p_effective_date date
, p_validation_start_date  date
, p_validation_end_date  date
, p_datetrack_mode   varchar2) is
--
  l_proc 	varchar2(72) := g_package||'hr_psf_bus';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_event = 'INSERT_VALIDATE' then
    pqh_psf_bus.hr_psf_bus_insert_validate(p_rec, p_effective_date);
  elsif p_event = 'UPDATE_VALIDATE' then
    pqh_psf_bus.hr_psf_bus_update_validate(p_rec, p_effective_date, p_validation_start_date,p_validation_end_date, p_datetrack_mode );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< per_asg_bus >-----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure per_asg_bus(p_event varchar2, p_rec  per_asg_shd.g_rec_type
      ,p_effective_date	       in date
      ,p_validation_start_date in date
      ,p_validation_end_date    in date
      ,p_datetrack_mode	       in varchar2) is
--
  l_proc 	varchar2(72) := g_package||'per_asg_bus';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_event = 'INSERT_VALIDATE' then
    pqh_psf_bus.per_asg_bus_insert_validate(p_rec, p_effective_date);
  elsif p_event = 'UPDATE_VALIDATE' then
    pqh_psf_bus.per_asg_bus_update_validate(p_rec,
                                            p_effective_date,
                                            p_validation_start_date,
                                            p_validation_end_date,
                                            p_datetrack_mode );
  elsif p_event = 'DELETE_VALIDATE' then
        pqh_psf_bus.per_asg_bus_delete_validate(
                 p_rec                   => p_rec
                ,p_effective_date        => p_effective_date
                ,p_validation_start_date => p_validation_start_date
                ,p_validation_end_date   => p_validation_end_date
                ,p_datetrack_mode        => p_datetrack_mode);
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< hr_lei_bus >------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure hr_lei_bus(p_event varchar2, p_rec  hr_lei_shd.g_rec_type) is
--
  l_proc 	varchar2(72) := g_package||'hr_psf_bus';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< hr_loc_bus >------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure hr_loc_bus(p_event varchar2, p_rec  hr_loc_shd.g_rec_type) is
--
  l_proc 	varchar2(72) := g_package||'hr_psf_bus';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end;
--
/*
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< hr_org_bus >------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure hr_oru_bus(p_event varchar2, p_rec  hr_oru_shd.g_rec_type) is
--
  l_proc 	varchar2(72) := g_package||'hr_psf_bus';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end;
--
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< pe_aei_bus >------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure pe_aei_bus(p_event varchar2, p_rec  pe_aei_shd.g_rec_type) is
--
  l_proc 	varchar2(72) := g_package||'hr_psf_bus';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< pe_pei_bus >------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure pe_pei_bus(p_event varchar2, p_rec  pe_pei_shd.g_rec_type) is
--
  l_proc 	varchar2(72) := g_package||'hr_psf_bus';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< pe_per_bus >------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure per_per_bus(p_event varchar2, p_rec  per_per_shd.g_rec_type) is
--
  l_proc 	varchar2(72) := g_package||'hr_psf_bus';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< per_apl_bus >------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure per_apl_bus(p_event varchar2, p_rec  per_apl_shd.g_rec_type) is
--
  l_proc 	varchar2(72) := g_package||'hr_psf_bus';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< pe_jei_bus >------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure pe_jei_bus(p_event varchar2, p_rec  pe_jei_shd.g_rec_type) is
--
  l_proc 	varchar2(72) := g_package||'hr_psf_bus';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< pe_poi_bus >------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure pe_poi_bus(p_event varchar2, p_rec  pe_poi_shd.g_rec_type) is
--
  l_proc 	varchar2(72) := g_package||'hr_psf_bus';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< per_job_bus >------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure per_job_bus(p_event varchar2, p_rec  per_job_shd.g_rec_type) is
--
  l_proc 	varchar2(72) := g_package||'hr_psf_bus';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< per_dpf_bus >------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure per_dpf_bus(p_event varchar2, p_rec  per_dpf_shd.g_rec_type) is
--
  l_proc 	varchar2(72) := g_package||'hr_psf_bus';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< per_pse_bus >------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure per_pse_bus(p_event varchar2, p_rec  per_pse_shd.g_rec_type) is
--
  l_proc 	varchar2(72) := g_package||'hr_psf_bus';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< per_jbr_bus >------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure per_jbr_bus(p_event varchar2, p_rec  per_jbr_shd.g_rec_type) is
--
  l_proc 	varchar2(72) := g_package||'hr_psf_bus';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< per_vgr_bus >------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure per_vgr_bus(p_event varchar2, p_rec  per_vgr_shd.g_rec_type) is
--
  l_proc 	varchar2(72) := g_package||'hr_psf_bus';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< per_ose_bus >------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure per_ose_bus(p_event varchar2, p_rec  per_ose_shd.g_rec_type) is
--
  l_proc 	varchar2(72) := g_package||'hr_psf_bus';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end;
--
--
--
function POSITION_CONTROL_ENABLED(p_org_structure_version_id number,
                                  p_organization_id number,
                                  p_business_group_id number) RETURN VARCHAR2 IS
--
CURSOR C1(p_org_structure_version_id number, P_ORGANIZATION_ID NUMBER, p_business_group_id number) IS
SELECT level, POSITION_CONTROL_ENABLED_FLAG
FROM
	PER_ORG_STRUCTURE_ELEMENTS A
where
    a.business_group_id = p_business_group_id
	start with  organization_id_child = P_ORGANIZATION_ID
          and ORG_STRUCTURE_VERSION_ID = P_ORG_STRUCTURE_VERSION_ID
	connect by organization_id_child = prior organization_id_parent
         and ORG_STRUCTURE_VERSION_ID = P_ORG_STRUCTURE_VERSION_ID;
--
CURSOR C2(p_org_structure_version_id number) IS
select organization_id_parent organization_id
from PER_ORG_STRUCTURE_ELEMENTS
where ORG_STRUCTURE_VERSION_ID = P_ORG_STRUCTURE_VERSION_ID
minus
select organization_id_child organization_id
from PER_ORG_STRUCTURE_ELEMENTS
where ORG_STRUCTURE_VERSION_ID = P_ORG_STRUCTURE_VERSION_ID;
--
cursor c3(p_org_structure_version_id number) is
select nvl(osv.topnode_pos_ctrl_enabled_flag,'N')
from per_org_structure_versions osv
where osv.ORG_STRUCTURE_VERSION_ID = P_ORG_STRUCTURE_VERSION_ID;
--
l_org_pc_enabled_null boolean := false;
l_top_org_id          number;
l_pc_enabled_flag     varchar2(10);
--
BEGIN
if p_organization_id is not null and p_org_structure_version_id is not null
   and p_business_group_id is not null then
  --
  FOR R_C1 IN C1(p_org_structure_version_id, P_ORGANIZATION_ID, p_business_group_id) LOOP
    IF R_C1.POSITION_CONTROL_ENABLED_FLAG IS NOT NULL THEN
      RETURN R_C1.POSITION_CONTROL_ENABLED_FLAG;
    else
      l_org_pc_enabled_null := true;
    END IF;
  END LOOP;
  open c3(p_org_structure_version_id);
  fetch c3 into l_pc_enabled_flag;
  close c3;
  if l_org_pc_enabled_null then
    return l_pc_enabled_flag;
  end if;
  open C2(p_org_structure_version_id);
  fetch c2 into l_top_org_id;
  close c2;
  if l_top_org_id = p_organization_id then
    return l_pc_enabled_flag;
  end if;
end if;
RETURN 'N';
END;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< per_asg_wf_sync>-----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure per_asg_wf_sync(p_event varchar2, p_rec  per_asg_shd.g_rec_type
      ,p_old_position_id       in number default null
      ,p_effective_date        in date
      ,p_validation_start_date in date
      ,p_validation_end_date    in date
      ,p_datetrack_mode        in varchar2) is
--
       myparms  wf_parameter_list_t;
       l_future_change  boolean;
       l_position_id    number;
       l_assignment_id  varchar2(15);
       l_old_position_id number;
       l_old_pos_id     number;
       l_future_date    date;
       l_proc           varchar2(30) := 'per_asg_wf_sync';
       l_start_date	date;
       l_expiration_date date;
       l_effective_start_date date;
       l_assg_start_date date;
       l_assg_end_date date;
       cnt number;
       l_cnt number;

       cursor get_eff_st_date(c_pos_id number) is
       select min(effective_start_date) into l_effective_start_date
       from per_all_assignments_f
       where assignment_id = l_assignment_id
       and assignment_type = 'E'
       and position_id = c_pos_id;
  begin
       hr_utility.set_location('Entering:'||l_proc, 5);
       --
       l_position_id := p_rec.position_id;
       l_assignment_id := p_rec.assignment_id;
       l_old_position_id := per_asg_shd.g_old_rec.position_id;
       l_assg_start_date := p_rec.effective_start_date;
       l_assg_end_date := p_rec.effective_end_date;
       l_old_pos_id  :=  p_old_position_id;
       --
       -- Check position budgeted amount
       --
       if (p_event in ('POST_INSERT', 'POST_UPDATE')) then
         if (p_rec.assignment_type = 'E') then
           if (l_position_id <> nvl(l_old_position_id,-1)) then
             pqh_psf_bus.chk_position_budget(
                           p_assignment_id  => l_assignment_id,
                           p_effective_date => p_effective_date,
                           p_called_from    => 'ASG',
                           p_old_position_id => l_old_position_id,
                           p_new_position_id => l_position_id);
           end if;
         end if;
       end if;
       --
       -- Assignment WF Synchronize
       --
     -- fix for bug 8945335 starts here
     -- if condn added to do wf synch only for E or C assignments (not for A)
     if (p_rec.assignment_type = 'E') or (p_rec.assignment_type = 'C')
     then
     -- fix for bug 8945335 ends here
       if l_old_pos_id is not null then

            if p_datetrack_mode = 'CORRECTION' then
               WF_LOCAL_SYNCH.propagate_user_role(p_user_orig_system  => 'PER',
                              p_user_orig_system_id   => p_rec.person_id,
                              p_role_orig_system      => 'POS',
                              p_role_orig_system_id   => l_old_pos_id,
                              p_start_date            => hr_general.end_of_time,
                              p_expiration_date       => hr_general.end_of_time);
            else
               open get_eff_st_date(l_old_pos_id);
               fetch get_eff_st_date into l_effective_start_date;
               close get_eff_st_date;
               WF_LOCAL_SYNCH.propagate_user_role(p_user_orig_system  => 'PER',
                              p_user_orig_system_id   => p_rec.person_id,
                              p_role_orig_system      => 'POS',
                              p_role_orig_system_id   => l_old_pos_id,
                              p_start_date            => l_effective_start_date,
                              p_expiration_date       => l_assg_start_date-1);

            end if;
        end if;
       if l_position_id is not null then
         WF_LOCAL_SYNCH.propagate_user_role(p_user_orig_system      => 'PER',
                              p_user_orig_system_id   => p_rec.person_id,
                              p_role_orig_system      => 'POS',
                              p_role_orig_system_id   => l_position_id,
                              p_start_date	      => l_assg_start_date,
                              p_expiration_date	      => l_assg_end_date);
       end if;
      -- fix for bug 8945335 starts here
     end if;
       -- fix for bug 8945335 ends here
       --
       hr_utility.set_location('Leaving:'||l_proc, 5);

  end;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< my_synch_routine >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure my_synch_routine(mykey in varchar2) is
--
cursor c_person(p_assignment_id varchar2) is
       SELECT USR.USER_NAME          USER_NAME,
       'PER'                         USER_ORIG_SYSTEM,
       PER.PERSON_ID                 USER_ORIG_SYSTEM_ID,
       'POS'||':'||POS.POSITION_ID   ROLE_NAME,
       'POS'                         ROLE_ORIG_SYSTEM,
       POS.POSITION_ID               ROLE_ORIG_SYSTEM_ID,
       PER.FULL_NAME                 USER_DISPLAY_NAME,
       'QUERY'                       NOTIFICATION_PREFERENCE,
       FNDL.NLS_LANGUAGE             LANGUAGE,
       FNDT.NLS_TERRITORY            TERRITORY,
       PER.EMAIL_ADDRESS             EMAIL_ADDRESS,
       NULL                          FAX,
       'ACTIVE'                      STATUS
from   PER_ALL_ASSIGNMENTS_F ASS,
       PER_ALL_POSITIONS  POS,
       FND_USER USR,
       PER_ALL_PEOPLE_F PER,
       FND_TERRITORIES FNDT,
       FND_LANGUAGES FNDL,
       HR_LOCATIONS HRL
where  ASS.ASSIGNMENT_ID = P_ASSIGNMENT_ID
and    ASS.POSITION_ID = POS.POSITION_ID
and    ASS.PERSON_ID   = USR.EMPLOYEE_ID
and    ASS.PERSON_ID   = PER.PERSON_ID
and    trunc(sysdate) between PER.EFFECTIVE_START_DATE
                          and PER.EFFECTIVE_END_DATE
and    trunc(sysdate) between ASS.EFFECTIVE_START_DATE
                          and ASS.EFFECTIVE_END_DATE
and    trunc(sysdate) between USR.START_DATE
                          and nvl(USR.END_DATE, sysdate+1)
and    PER.EMPLOYEE_NUMBER is not null
and    ASS.ASSIGNMENT_TYPE = 'E'
and     POS.LOCATION_ID         = HRL.LOCATION_ID(+)
and     HRL.COUNTRY             = FNDT.TERRITORY_CODE(+)
and     FNDT.NLS_TERRITORY      = FNDL.NLS_TERRITORY(+);
--
        cursor c_pos_exists(p_position_id number) is
        select 'x'
        from wf_roles -- wf_local_roles --(bug 2897533)
        where orig_system_id = p_position_id
        and   orig_system = 'POS';
--
        cursor c_user_exists(p_user_id varchar2) is
        select 'x'
        from wf_users --wf_local_users --(bug 2897533)
        where orig_system_id = p_user_id
        and   orig_system = 'PER';
--
/*
        cursor c_per_pos_del(p_person_id varchar2) is
        select 'x'
        from wf_user_roles --wf_local_user_roles --(bug 2897533)
        where user_orig_system_id = p_person_id
        and   user_orig_system = 'PER'
        and   role_orig_system = 'POS';
*/
--
        r_person     c_person%rowtype;
        l_assignment_id varchar2(15) := mykey;
        l_plist        wf_parameter_list_t;
        l_proc         varchar2(30) := 'MY_SYNC_ROUTINE';
        l_dummy        varchar2(10);
        l_dummy_pos    varchar2(10);
        l_dummy_user   varchar2(10);
--
      begin
        --
        if l_assignment_id is not null then
          open c_person(l_assignment_id);
          fetch c_person into r_person;

          hr_utility.set_location('ORIG SYSTEM ID: '|| r_person.USER_ORIG_SYSTEM_ID||l_proc, 5);
          hr_utility.set_location('ORIG SYSTEM:'|| r_person.USER_ORIG_SYSTEM|| l_proc, 5);
          hr_utility.set_location('ROLE ORIG SYSTEM:'|| r_person.ROLE_ORIG_SYSTEM|| l_proc, 5);

          if c_person%notfound then
            /*
            open c_per_pos_del(r_person.USER_ORIG_SYSTEM_ID);
            fetch c_per_pos_del into l_dummy;
            if c_per_pos_del%found then
              hr_utility.set_location('WF_SYNC set DELETE parameter true: '||l_proc, 10);
              wf_event.AddParameterToList('USER_NAME', r_person.ROLE_NAME,l_plist);
              wf_event.AddParameterToList('DELETE', 'TRUE',l_plist);
              wf_event.AddParameterToList( 'Raiseerrors', 'TRUE', l_plist);
              -- synch the wf_local_user table --
              hr_utility.set_location('Before deleting WF_SYNC package role_user: '
                                          || r_person.USER_NAME, 15);
              wf_local_synch.propagate_user_role(p_user_orig_system   => r_person.USER_ORIG_SYSTEM,
                                                 p_user_orig_system_id  => r_person.USER_ORIG_SYSTEM_ID,
                                                 p_role_orig_system  => r_person.ROLE_ORIG_SYSTEM,
                                                 p_role_orig_system_id => r_person.ROLE_ORIG_SYSTEM_ID);
              hr_utility.set_location('After deleting WF_SYNC role_user: '||l_proc, 20);
              --
            end if;
            */
            --
            close c_person;
            --
            return;
          end if;
          close c_person;
        end if;

        --
        -- construct the list of attributes using standard OID att names --
        --
        hr_utility.set_location('Before calling add parameters: '||l_proc, 20);
         wf_event.AddParameterToList( 'orclWFOrigSystem',r_person.ROLE_ORIG_SYSTEM,l_plist);
         wf_event.AddParameterToList( 'orclWFOrigSystemID',r_person.ROLE_ORIG_SYSTEM_ID,l_plist);
         wf_event.AddParameterToList( 'orclWorkFlowNotificationPref', r_person.NOTIFICATION_PREFERENCE, l_plist);
        wf_event.AddParameterToList('preferredLanguage',r_person.LANGUAGE,l_plist);
         wf_event.AddParameterToList( 'orclNLSTerritory', r_person.TERRITORY, l_plist);
         wf_event.AddParameterToList( 'orclIsEnabled', r_person.STATUS, l_plist);
         wf_event.AddParameterToList( 'WFSYNCH_OVERWRITE','TRUE',l_plist);
         wf_event.AddParameterToList( 'Raiseerrors', 'TRUE', l_plist);

        open c_pos_exists(r_person.ROLE_ORIG_SYSTEM_ID);
        fetch c_pos_exists into l_dummy_pos;

        if c_pos_exists%notfound then
           wf_event.AddParameterToList(
             p_name => 'USER_NAME',
             p_value => r_person.ROLE_NAME,
             p_parameterlist => l_plist);

       hr_utility.set_location('In Insert WF_SYNC role: '
                                          || r_person.ROLE_NAME, 25);


           WF_LOCAL_SYNCH.propagate_role(p_orig_system => r_person.ROLE_ORIG_SYSTEM,
                         p_orig_system_id => r_person.ROLE_ORIG_SYSTEM_ID,
                         p_attributes => l_plist);
       end if;

        open c_user_exists(r_person.USER_ORIG_SYSTEM_ID);
        fetch c_user_exists into l_dummy_user;

        if c_user_exists%notfound then
        hr_utility.set_location('In Insert WF_SYNC user: '
                                          || r_person.USER_NAME, 25);
           wf_event.AddParameterToList(
             p_name => 'USER_NAME',
             p_value => r_person.USER_NAME,
             p_parameterlist => l_plist);

           WF_LOCAL_SYNCH.propagate_user(p_orig_system => r_person.USER_ORIG_SYSTEM,
                         p_orig_system_id => r_person.USER_ORIG_SYSTEM_ID,
                         p_attributes => l_plist);
        end if;

        -- synch the wf_local_user table --
        hr_utility.set_location('Before calling WF_SYNC propagate user_role: '
                                          || r_person.USER_ORIG_SYSTEM_ID, 30);
              WF_LOCAL_SYNCH.propagate_user_role(
                              p_user_orig_system   => r_person.USER_ORIG_SYSTEM,
                              p_user_orig_system_id  => r_person.USER_ORIG_SYSTEM_ID,
                              p_role_orig_system  => r_person.ROLE_ORIG_SYSTEM,
                              p_role_orig_system_id => r_person.ROLE_ORIG_SYSTEM_ID);

        hr_utility.set_location('After calling WF_SYNC propagate user_role: '||l_proc, 35);
        --
      end my_synch_routine;
--
end per_pqh_shr;

/
