--------------------------------------------------------
--  DDL for Package Body HXC_APPROVAL_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_APPROVAL_REPORT_PKG" as
/* $Header: hxcaprrp.pkb 115.5 2002/12/19 10:57:19 vsuriana ship $ */
--  get_employee_name
--
-- procedure
-- Brings back the employee name for a given person id
-- description
--
-- parameters
--              p_person_id          - person Id
--
function get_employee_name(
         p_person_id in varchar2
         ) return varchar2
 is
 l_person_name varchar2(30);

begin
l_person_name := null;

if ( p_person_id is not null) then

  -- Perf Rep - SQL ID: 3168839
  -- select full_name into l_person_name
  -- from per_all_people_f
  -- where to_char(person_id) = p_person_id;

  select full_name into l_person_name
  from per_all_people_f
  where person_id = to_number(p_person_id);

end if;

return l_person_name;

end get_employee_name;

--  get_last_aprv
--
-- procedure
-- Brings back the last approver for a given Approval timecard  ID and OVN
-- parameters
--              p_timecard_id         - Application Period Building Block Id
--              p_timecard_ovn        - Application Period Building Block Ovn
--


function get_last_aprv(
               p_timecard_id in number,
               p_timecard_ovn in number)
           return varchar2
is
l_last_approver varchar2(30);
l_last_approver_id number;
begin

l_last_approver := null;

--
-- Selects the last approver Time Attribute Id
--
select max(htau_last_aprv.time_attribute_id ) INTO l_last_approver_id
from
hxc_time_building_blocks htb,
hxc_time_attribute_usages htau_last_aprv,
hxc_time_attributes hta_last_aprv
where
htb.time_building_block_id = p_timecard_id
and htb.object_version_number = p_timecard_ovn
and htb.time_building_block_id = htau_last_aprv.time_building_block_id
and htb.object_version_number = htau_last_aprv.time_building_block_ovn
and htau_last_aprv.time_attribute_id = hta_last_aprv.time_attribute_id
and hta_last_aprv.attribute_category = 'APPROVAL'
and hta_last_aprv.attribute4 = 'FINISHED' ;

if (l_last_approver_id is not null)
then
   select attribute3 into l_last_approver from hxc_time_attributes
   where time_attribute_id = l_last_approver_id ;
 end if;

 return l_last_approver;

end get_last_aprv;

--  get_project_name
--
-- procedure
-- Brings back the project name for a given project number
-- description
--
-- parameters
--              p_project_number         - project number
--

function get_project_name(
    p_project_number in varchar2
    ) return varchar2
 is
 l_project_name varchar2(100);
 begin
 l_project_name := null;


 if (p_project_number is not null)
 then
   select project_name into l_project_name
   from pa_online_projects_v
   where project_number = p_project_number;
 end if;
return l_project_name;
 end get_project_name;

--  get_task_name
--
-- procedure
-- Brings back the task name for a given task number
-- description
--
-- parameters
--              p_task_number  - Task number
--
 function get_task_name(
    p_task_number in varchar2
    ) return varchar2
 is
 l_task_name varchar2(100);
 begin
 l_task_name := null;


 if (p_task_number is not null)
 then
   select task_name into l_task_name
   from pa_online_tasks_v
   where task_number = p_task_number;
 end if;
return l_task_name;
 end get_task_name;

--  get_element_name
--
-- procedure
-- Brings back the element name for a given element type id
--
-- parameters
--              p_element_type_id         - element type id
--
-- returns
--              varchar2     -   element name

function get_element_name(
 p_element_type_id varchar2)  return varchar2
 is
 l_element_name varchar2(100);
 begin
  l_element_name := null;
   if(p_element_type_id  is not null )
   then
   	-- Perf Rep - SQL ID:3168908
   	-- select pet.element_name into l_element_name
        -- from pay_element_types_f  pet
        -- where to_char(pet.element_type_id) = p_element_type_id;

        select pet.element_name into l_element_name
        from pay_element_types_f  pet
        where pet.element_type_id = to_number(p_element_type_id);

   end if;
   return l_element_name;
 end get_element_name;

--  get_application_name
--
-- procedure
-- Brings back the application name for a given time recipient id
--
-- parameters
--              p_time_recipient_id         - Time Recipient Id
--
-- returns
--              varchar2     -   application Name


function get_application_name(
 p_time_recipient_id varchar2)  return varchar2
 is
 l_application_name varchar2(100);
 begin
  l_application_name := null;
   if(p_time_recipient_id  is not null )
   then
       select fav.application_name into l_application_name
       from hxc_time_recipients htr,fnd_application_vl fav
       where
       to_char(htr.time_recipient_id) = p_time_recipient_id
       and fav.application_id = htr.application_id;
   end if;
   return l_application_name;

 end get_application_name;

--  get_supervisor_name
--
-- procedure
-- Brings back the supervior for a given person
--
-- parameters
--              p_person_id         - person id
--
-- returns
--              varchar2     -   supervisor full name


function get_supervisor_name(
         p_person_id in number
         ) return varchar2
 is
 l_person_name varchar2(30);
 l_supervisor_id number;
begin
l_supervisor_id :=null;
l_person_name := null;

if ( p_person_id is not null) then
  select supervisor_id into l_supervisor_id
  from per_assignments_f
  where person_id = p_person_id;

  if (l_supervisor_id is not null) then

  	select full_name into l_person_name
  	from per_all_people_f
	 where person_id = l_supervisor_id ;
  end if;
end if;

return l_person_name;

end get_supervisor_name;

--  get_organization_name
--
-- procedure
-- Brings back the organization name for a given person
--
-- parameters
--              p_person_id         - person id
--
-- returns
--              varchar2     -   organization name

function get_organization_name(
         p_person_id in number
         ) return varchar2
 is
 l_organization_name varchar2(240);
 l_organization_id number;
begin
l_organization_name :=null;
l_organization_id  := null;

if ( p_person_id is not null) then
  select organization_id into l_organization_id
  from per_assignments_f
  where person_id = p_person_id;

  if (l_organization_id is not null) then
  	select name into l_organization_name
  	from per_organization_units
	where  organization_id = l_organization_id ;
  end if;
end if;

return l_organization_name;
end get_organization_name;

--  get_cost_center
--
-- procedure
-- Brings back the cost center for a given person
--
-- parameters
--              p_person_id         - person id
--
-- returns
--              varchar2     -   cost center

function get_cost_center(
         p_person_id in number
         ) return varchar2
 is
 l_cost_center varchar2(30);
 l_flex_id number;
begin
l_cost_center :=null;
l_flex_id  := null;

if ( p_person_id is not null) then
  select soft_coding_keyflex_id into l_flex_id
  from per_assignments_f
  where person_id = p_person_id;

  if (l_flex_id is not null) then
  	select  CONCATENATED_SEGMENTS    into l_cost_center
  	from pay_cost_allocation_keyflex
	where  cost_allocation_keyflex_id = l_flex_id ;
  end if;
end if;

return l_cost_center;

end get_cost_center;

function get_payroll_name(
         p_person_id in number
         ) return varchar2
 is
 l_payroll_name varchar2(30);
 l_payroll_id number;
begin
l_payroll_name :=null;
l_payroll_id  := null;

if ( p_person_id is not null) then
  select payroll_id into l_payroll_id
  from per_assignments_f
  where person_id = p_person_id;

  if (l_payroll_id is not null) then
  	select payroll_name into l_payroll_name
  	from pay_all_payrolls_f
	where  payroll_id= l_payroll_id ;
  end if;
end if;

return l_payroll_name;

end get_payroll_name;

function get_business_group_name(
         p_person_id in number
         ) return varchar2
 is
 l_bg_name varchar2(240);
 l_bg_id number;
begin
l_bg_name :=null;
l_bg_id  := null;

if ( p_person_id is not null) then
  select business_group_id into l_bg_id
  from per_all_people_f
  where person_id = p_person_id;

  if (l_bg_id is not null) then
   	select name into l_bg_name
   	from per_business_groups
   	where business_group_id = l_bg_id;
   end if;

end if;

return l_bg_name;

end get_business_group_name;


end  hxc_approval_report_pkg;

/
