--------------------------------------------------------
--  DDL for Package Body HR_APPROVAL_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_APPROVAL_CUSTOM" as
/* $Header: hrapcuwf.pkb 120.6.12010000.4 2008/08/06 08:31:55 ubhat ship $ */
-- ---------------------------------------------------------------------------
-- private package global declarations
-- ---------------------------------------------------------------------------
  g_package                 constant varchar2(31) := 'hr_approval_custom.';
--
-- ----------------------------------------------------------------------------
-- |------------------------------< get_routing_details1 >--------------------|
-- ----------------------------------------------------------------------------
function get_routing_details1
           (p_person_id in per_people_f.person_id%type)
         return per_people_f.person_id%type is
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  return(null);
end get_routing_details1;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< get_routing_details2 >--------------------|
-- ----------------------------------------------------------------------------
function get_routing_details2
           (p_person_id in per_people_f.person_id%type)
         return per_people_f.person_id%type is
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  return(null);
end get_routing_details2;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< get_routing_details3 >--------------------|
-- ----------------------------------------------------------------------------
function get_routing_details3
           (p_person_id in per_people_f.person_id%type)
         return per_people_f.person_id%type is
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  return(null);
end get_routing_details3;
-- ----------------------------------------------------------------------------
-- |------------------------------< get_routing_details4 >--------------------|
-- ----------------------------------------------------------------------------
function get_routing_details4
           (p_person_id in per_people_f.person_id%type)
         return per_people_f.person_id%type is
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  return(null);
end get_routing_details4;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< get_routing_details5 >--------------------|
-- ----------------------------------------------------------------------------
function get_routing_details5
           (p_person_id in per_people_f.person_id%type)
         return per_people_f.person_id%type is
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  return(null);
end get_routing_details5;
-- ----------------------------------------------------------------------------
-- |--------------------------< check_final_approver >------------------------|
-- ----------------------------------------------------------------------------
function check_final_approver
           (p_forward_to_person_id in per_people_f.person_id%type
           ,p_person_id            in per_people_f.person_id%type)
         return varchar2 is
--
  cursor csr_pa(l_effective_date in date) is
SELECT paf.person_id
FROM per_all_assignments_f paf START WITH paf.person_id = p_person_id
 AND paf.primary_flag = 'Y'
 AND paf.assignment_type IN('E',   'C')
 AND l_effective_date BETWEEN paf.effective_start_date
 AND paf.effective_end_date
 CONNECT BY PRIOR paf.supervisor_id = paf.person_id
 AND paf.primary_flag = 'Y'
 AND paf.assignment_type IN('E',   'C')
 AND l_effective_date BETWEEN paf.effective_start_date
 AND paf.effective_end_date;


--
  l_person_id per_people_f.person_id%type := null;
  l_employee  per_people_f.person_id%type := null;
--
begin
  -- check if the start of the chain is a valid employee
   begin
     select  ppf.person_id
     into l_employee
     from per_all_people_f ppf
     where ppf.person_id = p_person_id
     and  trunc(sysdate) between ppf.effective_start_date and  ppf.effective_end_date
     and  (ppf.current_employee_flag = 'Y' Or ppf.current_npw_flag = 'Y') ;
   exception
   when no_data_found then
          hr_utility.set_message(800,'HR_INVALID_PERSON_ID');
          hr_utility.set_message_token('PERSON_ID', p_person_id);
          hr_utility.raise_error;
   end;

  -- loop through each row. the rows are returned in an order which makes
  -- the last row selected the top most node of the chain.
  for lcsr in csr_pa(trunc(sysdate)) loop
    -- set the l_person_id variable to the row fetched
    l_person_id := lcsr.person_id;
     -- check if the l_person_id is valid employee
    begin
      select  ppf.person_id
      into l_employee
      from per_all_people_f ppf
      where ppf.person_id = l_person_id
      and  trunc(sysdate) between ppf.effective_start_date and  ppf.effective_end_date
      and  (ppf.current_employee_flag = 'Y' Or ppf.current_npw_flag = 'Y');
    exception
     when no_data_found then
          hr_utility.set_message(800,'HR_INVALID_PERSON_ID');
          hr_utility.set_message_token('PERSON_ID', l_person_id);
          hr_utility.raise_error;
    end;
  end loop;
  if p_forward_to_person_id = l_person_id then
  ------------add extra check to block auto approval---------------
   declare
   ed_date per_all_assignments_f.effective_end_date%type;
   l_disp_person_id  per_all_assignments_f.person_id%type;
   begin

select nvl(max(ppf.EFFECTIVE_END_DATE),sysdate+10)
into ed_date
from per_all_people_f ppf where ppf.person_id in (
select paf1.supervisor_id
     from per_all_assignments_f paf1
     where paf1.primary_flag = 'Y'
     and paf1.assignment_type in ('E','C')
     and paf1.person_id = l_person_id
     and paf1.supervisor_id is not null
     and paf1.EFFECTIVE_END_DATE = ( select max(paf.EFFECTIVE_END_DATE)
                                       from per_all_assignments_f paf
                                       where paf.primary_flag = 'Y'
                                       and paf.assignment_type in ('E','C')
                                       and paf.person_id = l_person_id
     )
)
and  (ppf.current_employee_flag = 'Y' Or ppf.current_npw_flag = 'Y');


     if ed_date < trunc(sysdate) then
      select distinct paf1.supervisor_id
      into l_disp_person_id
      from per_all_assignments_f paf1
      where paf1.primary_flag = 'Y'
      and paf1.assignment_type in ('E','C')
      and paf1.person_id = l_person_id
      and paf1.supervisor_id is not null
      and paf1.EFFECTIVE_END_DATE = ( select max(paf.EFFECTIVE_END_DATE)
                                        from per_all_assignments_f paf
                                        where paf.primary_flag = 'Y'
                                        and paf.assignment_type in ('E','C')
                                        and paf.person_id = l_person_id
      );

       hr_utility.set_message(800,'HR_INVALID_PERSON_ID');
       hr_utility.set_message_token('PERSON_ID', l_disp_person_id);
       hr_utility.raise_error;
     end if;
    exception
    when no_data_found then
      raise;
    when others then
      raise;
    end;
------------add extra check to block auto approval---------------
    return('Y');
  else
    return('N');
  end if;
exception
  when others then
       raise;
--
end check_final_approver;
-- ----------------------------------------------------------------------------
-- |--------------------------< check_final_payroll_notifier >----------------|
-- ----------------------------------------------------------------------------
function check_final_payroll_notifier
           (p_forward_to_person_id in per_people_f.person_id%type
           ,p_person_id            in per_people_f.person_id%type)
         return varchar2 is
begin
  -- [CUSTOMIZE]
  return('Y');
end check_final_payroll_notifier;
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_next_approver >------------------------|
-- ----------------------------------------------------------------------------
function get_next_approver
           (p_person_id in per_people_f.person_id%type)
         return per_people_f.person_id%type is
--
  cursor csr_pa(l_effective_date in date
               ,l_in_person_id   in per_people_f.person_id%type) is
   /*
    -- Modified the cursor to support Contingent Worker
    -- Fix for bug#2949844
    select  ppf.person_id
    from    per_all_assignments_f paf
           -- fix for bug # 1677216
           --,per_people_f      ppf
           ,per_all_people_f      ppf
    where   paf.person_id             = l_in_person_id
    and     paf.primary_flag          = 'Y'
    and     l_effective_date
    between paf.effective_start_date
    and     paf.effective_end_date
    and     ppf.person_id             = paf.supervisor_id
    and     ppf.current_employee_flag = 'Y'
    and     l_effective_date
    between ppf.effective_start_date
    and     ppf.effective_end_date;
   */
     -- modified cursor to handle the issues reported
     -- in bug#3007859
    select  ppf.person_id
    from    per_all_assignments_f paf
           ,per_all_people_f      ppf
    where   paf.person_id             = l_in_person_id
    and      paf.primary_flag = 'Y'
       and     trunc(sysdate)
       between paf.effective_start_date
       and     paf.effective_end_date
       and     paf.assignment_type in ('E','C')
       and     paf.assignment_status_type_id not in
                                 (select assignment_status_type_id
                                  from per_assignment_status_types
                                where per_system_status = 'TERM_ASSIGN' and business_group_id=paf.business_group_id)
    and     ppf.person_id  = paf.supervisor_id
    and     (ppf.current_employee_flag = 'Y' Or ppf.current_npw_flag = 'Y')
    and     trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date;
--

--
  l_out_person_id per_people_f.person_id%type default null;
--
begin
  -- [CUSTOMIZE]
  -- open the candidate select cursor
  open csr_pa(trunc(sysdate), p_person_id);
  -- fetch the candidate details
  fetch csr_pa into l_out_person_id;
  if csr_pa%notfound then
    -- if the cursor does not return a row then we must set the out
    -- parameter to null
    l_out_person_id := null;
  end if;
  -- close the cursor
  close csr_pa;
  return(l_out_person_id);
end get_next_approver;

-- ----------------------------------------------------------------------------
-- |-----------------------------< get_next_payroll_notifier >----------------|
-- ----------------------------------------------------------------------------
function get_next_payroll_notifier
           (p_person_id in per_people_f.person_id%type)
         return per_people_f.person_id%type is
begin
   -- [CUSTOMIZE]
   return null;
end get_next_payroll_notifier;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL1 >-----------------------------|
-- ------------------------------------------------------------------------
function get_URL1 return varchar2 is
  --
  -- Declare and intialise the URL to display the review approval page
  l_url varchar2(2000)  := NULL;
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  return(l_url);
end get_URL1;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL2 >-----------------------------|
-- ------------------------------------------------------------------------
function get_URL2 return varchar2 is
  --
  -- Declare and intialise the URL to display the view and resubmit URL
  --
  l_url varchar2(2000)  := NULL;
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  return(l_url);
end get_URL2;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL3 >-----------------------------|
-- ------------------------------------------------------------------------
function get_URL3 return varchar2 is
  --
  -- Declare and intialise the URL
  l_url varchar2(2000)  := NULL;
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  return(l_url);
end get_URL3;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL4 >-----------------------------|
-- ------------------------------------------------------------------------
function get_URL4 return varchar2 is
  --
  -- Declare and intialise the URL
  l_url varchar2(2000)  := NULL;
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  return(l_url);
end get_URL4;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL5 >-----------------------------|
-- ------------------------------------------------------------------------
function get_URL5 return varchar2 is
  --
  -- Declare and intialise the URL
  l_url varchar2(2000)  := NULL;
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  return(l_url);
end get_URL5;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL6 >-----------------------------|
-- ------------------------------------------------------------------------
function get_URL6 return varchar2 is
  --
  -- Declare and intialise the URL
  l_url varchar2(2000)  := NULL;
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  return(l_url);
end get_URL6;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL7 >-----------------------------|
-- ------------------------------------------------------------------------
function get_URL7 return varchar2 is
  --
  -- Declare and intialise the URL
  l_url varchar2(2000)  := NULL;
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  return(l_url);
end get_URL7;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL8 >-----------------------------|
-- ------------------------------------------------------------------------
function get_URL8 return varchar2 is
  --
  -- Declare and intialise the URL
  l_url varchar2(2000)  := NULL;
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  return(l_url);
end get_URL8;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL9 >-----------------------------|
-- ------------------------------------------------------------------------
function get_URL9 return varchar2 is
  --
  -- Declare and intialise the URL
  l_url varchar2(2000)  := NULL;
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  return(l_url);
end get_URL9;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL10 >-----------------------------|
-- ------------------------------------------------------------------------
function get_URL10 return varchar2 is
  --
  -- Declare and intialise the URL
  l_url varchar2(2000)  := NULL;
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  return(l_url);
end get_URL10;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL11 >-----------------------------|
-- ------------------------------------------------------------------------
function get_URL11 return varchar2 is
  --
  -- Declare and intialise the URL
  l_url varchar2(2000)  := NULL;
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  return(l_url);
end get_URL11;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL12 >-----------------------------|
-- ------------------------------------------------------------------------
function get_URL12 return varchar2 is
  --
  -- Declare and intialise the URL
  l_url varchar2(2000)  := NULL;
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  return(l_url);
end get_URL12;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL13 >-----------------------------|
-- ------------------------------------------------------------------------
function get_URL13 return varchar2 is
  --
  -- Declare and intialise the URL
  l_url varchar2(2000)  := NULL;
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  return(l_url);
end get_URL13;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL14 >-----------------------------|
-- ------------------------------------------------------------------------
function get_URL14 return varchar2 is
  --
  -- Declare and intialise the URL
  l_url varchar2(2000)  := NULL;
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  return(l_url);
end get_URL14;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL15 >-----------------------------|
-- ------------------------------------------------------------------------
function get_URL15 return varchar2 is
  --
  -- Declare and intialise the URL
  l_url varchar2(2000)  := NULL;
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  return(l_url);
end get_URL15;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL16 >-----------------------------|
-- ------------------------------------------------------------------------
function get_URL16 return varchar2 is
  --
  -- Declare and intialise the URL
  l_url varchar2(2000)  := NULL;
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  return(l_url);
end get_URL16;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL17 >-----------------------------|
-- ------------------------------------------------------------------------
function get_URL17 return varchar2 is
  --
  -- Declare and intialise the URL
  l_url varchar2(2000)  := NULL;
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  return(l_url);
end get_URL17;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL18 >-----------------------------|
-- ------------------------------------------------------------------------
function get_URL18 return varchar2 is
  --
  -- Declare and intialise the URL
  l_url varchar2(2000)  := NULL;
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  return(l_url);
end get_URL18;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL19 >-----------------------------|
-- ------------------------------------------------------------------------
function get_URL19 return varchar2 is
  --
  -- Declare and intialise the URL
  l_url varchar2(2000)  := NULL;
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  return(l_url);
end get_URL19;
-- ------------------------------------------------------------------------
-- |------------------------------< get_URL20 >-----------------------------|
-- ------------------------------------------------------------------------
function get_URL20 return varchar2 is
  --
  -- Declare and intialise the URL
  l_url varchar2(2000)  := NULL;
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  return(l_url);
end get_URL20;
-- ----------------------------------------------------------------------------
-- |-----------------------< check_if_in_approval_chain >---------------------|
-- ----------------------------------------------------------------------------
function check_if_in_approval_chain
           (p_forward_to_person_id in per_people_f.person_id%type
           ,p_person_id            in per_people_f.person_id%type)
         return boolean is
--
  l_in_chain          boolean := false;
  l_current_person_id per_people_f.person_id%type := p_person_id;
  l_person_id         per_people_f.person_id%type;
--
begin
  --
  while l_current_person_id is not null loop
    if l_current_person_id = p_forward_to_person_id then
      l_in_chain := true;
      exit;
    else
      l_current_person_id := get_next_approver
                               (p_person_id => l_current_person_id);
    end if;
  end loop;
  return(l_in_chain);
end check_if_in_approval_chain;
--
end hr_approval_custom;

/
