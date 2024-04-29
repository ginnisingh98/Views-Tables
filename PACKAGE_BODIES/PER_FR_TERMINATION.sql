--------------------------------------------------------
--  DDL for Package Body PER_FR_TERMINATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_FR_TERMINATION" as
/* $Header: pefrterm.pkb 120.4 2007/04/30 11:08:36 abhaduri noship $ */
--
g_package varchar2(30) := 'per_fr_termination';
g_person_id number;
g_validation number := 0;
--
/* --------------------------------------------------------------------
Local procedure to retrieve the Person ID from the period of service ID
   -------------------------------------------------------------------- */
procedure initiate(p_period_of_service_id number) is
--
cursor c_get_pds is
select person_id
from per_periods_of_service
where period_of_service_id = p_period_of_service_id;
--
l_proc varchar2(72) := g_package || '.intiate';
begin
hr_utility.set_location(l_proc,10);
  open c_get_pds;
  fetch c_get_pds into g_person_id;
  close c_get_pds;
end initiate;
  --
/* --------------------------------------------------------------------
Local function to determine whether the Leaving Reason has a corresponding
value in FR_ENDING_REASON and CONTRACT_END_REASON
   -------------------------------------------------------------------- */
function validate_leaving_reason
(p_lookup_type varchar2
,p_lookup_code varchar2) return boolean is
--
l_dummy varchar2(1);
--
cursor c_get_lkp is
select null
from hr_lookups
where lookup_type = p_lookup_type
and lookup_code = p_lookup_code;
--
l_proc varchar2(72) := g_package || '.validate_leaving_reason';
begin
hr_utility.set_location(l_proc,10);
  open c_get_lkp;
  fetch c_get_lkp into l_dummy;
  if c_get_lkp%found then
     close c_get_lkp;
     hr_utility.set_location(l_proc,20);
     return TRUE;
  else
     close c_get_lkp;
     hr_utility.set_location(l_proc,30);
     return FALSE;
  end if;
end validate_leaving_reason;
--
/* --------------------------------------------------------------------
Local procedure to perform validation of French specific columns.
   -------------------------------------------------------------------- */
procedure validate
(p_actual_termination_date date
,p_actual_termination_date_o date
,p_notice_period_start_date date
,p_notice_period_start_date_o date
,p_notice_period_end_date date
,p_notice_period_end_date_o date
,p_last_day_worked varchar2
,p_last_day_worked_o varchar2
,p_final_process_date date -- for  bug#5191942
) is
--
l_exists varchar2(1);
--
cursor c_future_contracts is
select null
from per_contracts_f
where person_id = g_person_id
and effective_start_date > p_actual_termination_date + 1
and substrb(status,1,2) = 'A-';
--
l_nps_changed boolean :=
   (p_notice_period_start_date is not null
   and (p_notice_period_start_date_o is null
     or (p_notice_period_start_date <> p_notice_period_start_date_o
     and p_notice_period_start_date_o is not null
        )));
l_npe_changed boolean :=
   (p_notice_period_end_date is not null
   and (p_notice_period_end_date_o is null
     or (p_notice_period_end_date <> p_notice_period_end_date_o
     and p_notice_period_end_date_o is not null
        )));
l_lwd_changed boolean :=
   (p_last_day_worked is not null
   and (p_last_day_worked_o is null
     or (p_last_day_worked <> p_last_day_worked_o
     and p_last_day_worked_o is not null
        )));
--
l_proc varchar2(72) := g_package || '.validate';
begin
hr_utility.set_location(l_proc,10);
--
-- Added for bug#5191942
-- if final process date is on or before actual termination date
-- then raise an error
hr_utility.set_location(l_proc, 10);
/*if p_final_process_date is not null
   and p_actual_termination_date is not null then
   if p_final_process_date < p_actual_termination_date
     or p_final_process_date = p_actual_termination_date then
     --
     hr_utility.set_message(800, 'PER_75099_FINAL_CLOSE_ATD');
     hr_utility.raise_error;
     --
   end if;
end if;*/
--
-- If either the NPS or NPE have changed and if either is NOT NULL then
-- validate that NPS is not after NPE
--
hr_utility.set_location(l_proc,20);
   if l_nps_changed or l_npe_changed then
       if p_notice_period_start_date > p_notice_period_end_date then
            hr_utility.set_message(800,'PER_75013_NOTICE_PERIOD_DATES');
            hr_utility.raise_error;
       end if;
    end if;
--
-- If NPS has changed or LWD has changed then ensure that
-- Notice period start is not later than LWD
--
hr_utility.set_location(l_proc,30);
   if l_nps_changed or l_lwd_changed then
      if p_notice_period_start_date > p_last_day_worked then
            hr_utility.set_message(800,'PER_75014_NPS_LWD_DATES');
            hr_utility.raise_error;
      end if;
   end if;
--
-- If NPE has changed or LWD has changed then ensure that
-- Notice period end is not earlier than LWD
--
hr_utility.set_location(l_proc,40);
   if l_npe_changed or l_lwd_changed then
      if p_notice_period_end_date < p_last_day_worked then
            hr_utility.set_message(800,'PER_75015_NPE_LWD_DATES');
            hr_utility.raise_error;
      end if;
   end if;
--
-- If NPE is not null then NPS must also be not null
--
hr_utility.set_location(l_proc,50);
   if p_notice_period_start_date is null
   and p_notice_period_end_date is not null then
            hr_utility.set_message(800,'PER_75016_NPS_NPE_DATES');
            hr_utility.raise_error;
   end if;
--
-- If ATD is not null then it must be on or after NPS and
-- on or before NPE
--
hr_utility.set_location(l_proc,60);
   if p_actual_termination_date is not null
   and p_notice_period_start_date is not null
   and p_notice_period_end_date is not null then
      if p_notice_period_start_date > p_actual_termination_date
      or p_notice_period_end_date < p_actual_termination_date then
            hr_utility.set_message(800,'PER_75017_NPS_ATD_DATES');
            hr_utility.raise_error;
      end if;
   end if;
--
-- If ATD is not null and LWD is not null then LWD must be on or
-- before ATD
--
hr_utility.set_location(l_proc,70);
  if p_actual_termination_date is not null
  and p_last_day_worked is not null then
      if p_last_day_worked > p_actual_termination_date then
            hr_utility.set_message(800,'PER_75018_LWD_ATD_DATES');
            hr_utility.raise_error;
      end if;
  end if;
--
-- If ATD is not null then LWD must be entered
--
hr_utility.set_location(l_proc,80);
  if p_actual_termination_date is not null
  and p_last_day_worked is null then
            hr_utility.set_message(800,'PER_75019_LWD_ATD_NULL');
            hr_utility.raise_error;
  end if;
--
hr_utility.set_location(l_proc,90);
end validate;
--
/* -------------------------------------------------------------------------
Local procedure to delete and create the element entry
FR_LAST_DAY_WORKED on LWD.
This is called from Terminate and Revers.
In the case of Reverse only the delete is performed.
   ----------------------------------------------------------------------- */
procedure last_day_worked_entry
(p_last_day_worked date
,p_actual_termination_date date) is
--
l_assignment_id number;
l_effective_date date;
l_element_type_id number;
l_element_link_id number;
l_element_entry_id number;
l_effective_start_date date;
l_effective_end_date date;
l_element_name pay_element_types_f.element_name%Type;
l_input_value_id Number;
--
cursor c_get_asg is
select assignment_id
from per_all_assignments_f
where person_id = g_person_id
and   l_effective_date
      between effective_start_date and effective_end_date
and primary_flag = 'Y';
--
cursor c_element is
select element_type_id, element_name
from pay_element_types_f
where l_effective_date
   between effective_start_date and effective_end_date
and element_name IN ('FR_LAST_DAY_WORKED', 'FR_TERMINATION_INFORMATION')
and legislation_code = 'FR';
--

cursor c_input_value is
select input_value_id
from pay_input_values_f
where l_effective_date
   between effective_start_date and effective_end_date
and legislation_code = 'FR'
and element_type_id = l_element_type_id
and name = 'Proration';

cursor c_entry is
select element_entry_id
from pay_element_entries_f ee
,    pay_element_links_f l
where ee.assignment_id = l_assignment_id
and   l.element_type_id = l_element_type_id
and   l.element_link_id = ee.element_link_id
and p_actual_termination_date
   between ee.effective_start_date and ee.effective_end_date
and p_actual_termination_date
   between l.effective_start_date and l.effective_end_date;
--
l_proc varchar2(72) := g_package || '.last_day_worked_entry';
begin
hr_utility.set_location(l_proc,10);
--
-- Get the FR_LAST_DAY_WORKED element type ID as of Actual Termination Date
--
  l_effective_date := p_actual_termination_date;
  open c_element;
  LOOP
          fetch c_element into l_element_type_id, l_element_name;
          EXIT WHEN c_element%NOTFOUND;
        --
        -- Get assignment ID of the primary assignment
        --
          if l_element_type_id is not null then
                 open c_get_asg;
                 fetch c_get_asg into l_assignment_id;
                 close c_get_asg;
        --
        -- Remove any existing element entry effective as of ATD
        --
        hr_utility.set_location(l_proc,20);
                 open c_entry;
                 fetch c_entry into l_element_entry_id;
                 if c_entry%found then
                        hr_entry_api.delete_element_entry
                        ('ZAP'
                        ,p_actual_termination_date
                        ,l_element_entry_id);
                        close c_entry;
                 else
                        close c_entry;
                 end if;
        --
        -- Now, if called from Terminate process, create new element entry
        -- effective as of LWD
        --
        hr_utility.set_location(l_proc,30);
                 if p_last_day_worked is not null then
                        l_effective_date := p_last_day_worked;
                        open c_get_asg;
                        fetch c_get_asg into l_assignment_id;
                        close c_get_asg;
                        --
                        l_element_link_id :=
                                hr_entry_api.get_link(l_assignment_id
                                                                         ,l_element_type_id
                                                                         ,p_last_day_worked);
                        --
                        l_effective_start_date := p_last_day_worked;
                        --
                        if l_element_link_id is not null then
                           hr_entry_api.insert_element_entry
                           (p_effective_start_date  => l_effective_start_date
                           ,p_effective_end_date    => l_effective_end_date
                           ,p_element_entry_id      => l_element_entry_id
                           ,p_assignment_id         => l_assignment_id
                           ,p_element_link_id       => l_element_link_id
                           ,p_creator_type          => 'F'
                           ,p_entry_type            => 'E');

        --
        -- Force DT change when ever entry is created on day after last day worked.
        -- A dummy input value is changed so that proration will occur.
        --
                           IF l_element_name = 'FR_LAST_DAY_WORKED' THEN

                hr_utility.set_location('l_elemen_type_id'||l_element_type_id, 100);
                hr_utility.set_location('l_assignment_id'||l_assignment_id, 100);
                hr_utility.set_location('l_element_link_id'||l_element_link_id, 100);
                                Open c_input_value;
                                Fetch c_input_value into l_input_value_id;
                                Close c_input_value;
                hr_utility.set_location('l_input_value_id'||l_input_value_id, 100);
                hr_utility.set_location('LWD'|| p_last_day_worked, 100);
                hr_utility.set_location('ATD'|| p_actual_termination_date, 100);
                                IF l_input_value_id IS NOT NULL THEN
                hr_utility.set_location('DT Updating EE ', 100);
                                   IF p_last_day_worked < p_actual_termination_date THEN
                hr_utility.set_location('Updating EE with LWD date='|| (p_last_day_worked + 1), 100);
                                     hr_entry_api.update_element_entry
                                     (p_dt_update_mode       => 'UPDATE'
                                     ,p_session_date         => p_last_day_worked + 1
                                     ,p_element_entry_id     => l_element_entry_id
                                     ,p_comment_id           => Null
                                     ,p_input_value_id1      => l_input_value_id
                                     ,p_entry_value1         => '2'
                                     );
                                   END IF;
                                   -- Bug #2884200
                hr_utility.set_location('Updating EE with ATD date='||(p_actual_termination_date + 1), 100);
                -- Bug#6003309
                hr_utility.set_location('Checking if ATD = FPD', 100);
                                  IF p_actual_termination_date <> l_effective_end_date THEN
                                     hr_entry_api.update_element_entry
                                     (p_dt_update_mode       => 'UPDATE'
                                     ,p_session_date         => p_actual_termination_date + 1
                                     ,p_element_entry_id     => l_element_entry_id
                                     ,p_comment_id           => Null
                                     ,p_input_value_id1      => l_input_value_id
                                     ,p_entry_value1         => '3'
                                     );
                                  END IF;
                                END IF; -- Input value id is not null
                           END IF;      -- element is 'FR_LAST_DAY_WORKED'
                        end if;
                 end if; -- if p_last_day_worked is not null
           end if; -- if l_element_type_id is not null
        END LOOP;
        CLOSE c_element;
--
hr_utility.set_location(l_proc,40);
--
end last_day_worked_entry;
--
/* -------------------------------------------------------------------------
local procedure to correct the assignment ending on ATD setting the
leaving reason to that on the period of service
   ----------------------------------------------------------------------- */
procedure correct_assignment(p_period_of_service_id number
                            ,p_actual_termination_date date
                            ,p_leaving_reason varchar2) is
--
l_proc varchar2(72) := g_package||'.correct_assignment';
--
l_object_version_number number;
l_concatenated_segments varchar2(2000);
l_soft_coding_keyflex_id number;
l_comment_id  number;
l_effective_start_date date;
l_effective_end_date date;
l_no_managers_warning boolean;
l_other_manager_warning boolean;
l_effective_date date;
l_update_mode varchar2(30);
l_exists varchar2(30);
l_contract_id number;
l_active_contracts number;
l_all_contracts number;
l_leaving_reason varchar2(30);
--
cursor c_get_asg is
select a.assignment_id
,      a.primary_flag
,      a.object_version_number
,      a.soft_coding_keyflex_id
,      scl.segment4
,      scl.segment2
from per_all_assignments_f a
,    hr_soft_coding_keyflex scl
,    per_assignment_status_types ast
where a.period_of_service_id = p_period_of_service_id
and   p_actual_termination_date = a.effective_end_date
and   a.assignment_status_type_id = ast.assignment_status_type_id
and   ast.per_system_status <> 'TERM_ASSIGN'
and a.soft_coding_keyflex_id = scl.soft_coding_keyflex_id (+);
--
begin
hr_utility.set_location(l_proc,10);
--
-- Process assignments ending on Actual Termination Date - set End Reason
--
      if p_leaving_reason is null or
         not validate_leaving_reason('FR_ENDING_REASON',p_leaving_reason) then
         l_leaving_reason := null;
      else
         l_leaving_reason := p_leaving_reason;
      end if;
      --
      for a in c_get_asg loop
hr_utility.trace(a.assignment_id);
hr_utility.trace(p_period_of_service_id);
hr_utility.trace(p_actual_termination_date);
         l_object_version_number := a.object_version_number;
         hr_assignment_api.update_emp_asg
         (P_VALIDATE                     => FALSE
         ,P_EFFECTIVE_DATE               => p_actual_termination_date
         ,P_DATETRACK_UPDATE_MODE        => 'CORRECTION'
         ,P_ASSIGNMENT_ID                => a.assignment_id
         ,P_OBJECT_VERSION_NUMBER        => l_object_version_number
         ,P_SEGMENT2                     => a.segment2
         ,P_SEGMENT4                     => l_leaving_reason
         ,P_CONCATENATED_SEGMENTS        => l_concatenated_segments
         ,P_SOFT_CODING_KEYFLEX_ID       => l_soft_coding_keyflex_id
         ,P_COMMENT_ID                   => l_comment_id
         ,P_EFFECTIVE_START_DATE         => l_effective_start_date
         ,P_EFFECTIVE_END_DATE           => l_effective_end_date
         ,P_NO_MANAGERS_WARNING          => l_no_managers_warning
         ,P_OTHER_MANAGER_WARNING        => l_other_manager_warning);
      end loop;
--
hr_utility.set_location(l_proc,20);
end correct_assignment;
--

--
/* -------------------------------------------------------------------------
public procedure called from HR_EX_EMPLOYEE_BK1.ACTUAL_TERMINATION_EMP_A hook
to process assignments after they have been terminated to set leaving reason on
the record ending on ATD
   ----------------------------------------------------------------------- */
procedure actual_termination(p_period_of_service_id number
                            ,p_actual_termination_date date) is
--
l_proc varchar2(72) := g_package||'.actual_termination';
l_leaving_reason varchar2(30);
--
cursor c_get_pds is
select leaving_reason
from per_periods_of_service
where period_of_service_id = p_period_of_service_id;
--
begin

--
/* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'FR') THEN
   hr_utility.set_location('Leaving : '||l_proc , 10);
   return;
END IF;
--
hr_utility.set_location(l_proc,10);
hr_utility.trace('Actually Terminating');
   open c_get_pds;
   fetch c_get_pds into l_leaving_reason;
   close c_get_pds;
   --
   correct_assignment(p_period_of_service_id
                     ,p_actual_termination_date
                     ,l_leaving_reason);
hr_utility.set_location(l_proc,20);
end;
--
/* -------------------------------------------------------------------------
External procedure called from Termination API Row Handler After Update
hook call for France.
N.B. The Termination process as called from the form will call this procedure
3 times:
1. to update HR attributes
2. to maintain ATD
3. to maintain FPD

In 1. the ATD if changing is not available
In 2. the DDF segment changes are not available (both old and new values
are the same)
In 3. no hook processing is required.

Hence it is necessary to detect programatically then termination is happening
as opposed to just an update to the HR attributes (i.e DDF, Leaving Reason).
   ----------------------------------------------------------------------- */
procedure termination
(p_period_of_service_id number
,p_actual_termination_date date
,p_leaving_reason varchar2
,p_pds_information8 varchar2
,p_pds_information9 varchar2
,p_pds_information10 varchar2
,p_actual_termination_date_o date
,p_leaving_reason_o varchar2
,p_pds_information8_o varchar2
,p_pds_information9_o varchar2
,p_pds_information10_o varchar2
,p_final_process_date date -- for  bug#5191942
) is
--
l_proc varchar2(72) := g_package||'.termination';
--
l_notice_period_start_date date :=
     fnd_date.canonical_to_date(p_pds_information8);
l_notice_period_end_date date :=
     fnd_date.canonical_to_date(p_pds_information9);
l_last_day_worked date :=
     fnd_date.canonical_to_date(p_pds_information10);
--
l_notice_period_start_date_o date :=
     fnd_date.canonical_to_date(p_pds_information8_o);
l_notice_period_end_date_o date :=
     fnd_date.canonical_to_date(p_pds_information9_o);
l_last_day_worked_o date :=
     fnd_date.canonical_to_date(p_pds_information10_o);
--
l_object_version_number number;
l_concatenated_segments varchar2(2000);
l_soft_coding_keyflex_id number;
l_comment_id  number;
l_effective_start_date date;
l_effective_end_date date;
l_no_managers_warning boolean;
l_other_manager_warning boolean;
l_effective_date date;
l_update_mode varchar2(30);
l_exists varchar2(30);
l_contract_id number;
l_active_contracts number;
l_all_contracts number;
l_leaving_reason varchar2(30);
--
cursor c_get_asg is
select a.assignment_id
,      a.primary_flag
,      a.object_version_number
,      a.soft_coding_keyflex_id
,      scl.segment4
,      scl.segment2
from per_all_assignments_f a
,    hr_soft_coding_keyflex scl
where a.period_of_service_id = p_period_of_service_id
and   p_actual_termination_date = a.effective_end_date
and a.soft_coding_keyflex_id = scl.soft_coding_keyflex_id (+);
--
cursor c_get_ctr is
select contract_id
,      person_id
,      object_version_number
,      reference
,      type
,      status
,effective_start_date
,effective_end_date
from    per_contracts_f c
where  person_id = g_person_id
and l_effective_date between effective_start_date and effective_end_date
and substrb(status,1,2) = 'A-';
--
l_atd_changed boolean :=
    (p_actual_termination_date is not null and
     p_actual_termination_date_o is null);
l_leaving_reason_changed boolean :=
    (p_leaving_reason is not null and
     p_leaving_reason_o is not null and
     p_leaving_reason <> p_leaving_reason_o)
    or
    (p_leaving_reason is null and
     p_leaving_reason_o is not null)
    or
    (p_leaving_reason_o is null and
     p_leaving_reason is not null);
l_lwd_changed boolean :=
   (l_last_day_worked is not null
   and (l_last_day_worked_o is null
     or (l_last_day_worked <> l_last_day_worked_o
     and l_last_day_worked_o is not null
        )));

begin
--
/* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'FR') THEN
   hr_utility.set_location('Leaving : '||l_proc , 10);
   return;
END IF;
--
hr_utility.set_location(l_proc,10);
--
-- Initiate Person ID package variable
--
  initiate(p_period_of_service_id);
--
-- Perform validation of DDF segments
--
  validate(p_actual_termination_date
          ,p_actual_termination_date_o
          ,l_notice_period_start_date
          ,l_notice_period_start_date_o
          ,l_notice_period_end_date
          ,l_notice_period_end_date_o
          ,l_last_day_worked
          ,l_last_day_worked_o
          ,p_final_process_date);
--
-- If Terminating (ATD not null and ATD_Old is null)
-- then change contract to change status to Inactive on day after
-- ATD
--
-- This needs to take into account future changes to contract
--
hr_utility.set_location(l_proc,20);
   if l_atd_changed then
      l_effective_date := p_actual_termination_date + 1;
      for c in c_get_ctr loop
          l_object_version_number := c.object_version_number;
          --
          if c.effective_start_date = l_effective_date then
             l_update_mode := 'CORRECTION';
          elsif c.effective_end_date < hr_general.end_of_time then
                l_update_mode := 'UPDATE_CHANGE_INSERT';
          else
                l_update_mode := 'UPDATE';
          end if;
--
-- Create or update contract on day after ATD
--
hr_utility.trace(c.contract_id||' '||l_update_mode);
          hr_contract_api.update_contract
          (P_VALIDATE                     => FALSE
          ,P_CONTRACT_ID                  => c.contract_id
          ,P_EFFECTIVE_START_DATE         => l_effective_start_date
          ,P_EFFECTIVE_END_DATE           => l_effective_end_date
          ,P_OBJECT_VERSION_NUMBER        => l_object_version_number
          ,P_PERSON_ID                    => c.person_id
          ,P_REFERENCE                    => c.reference
          ,P_TYPE                         => c.type
          ,P_STATUS                       => 'T-TERMINATION'
          ,P_EFFECTIVE_DATE               => p_actual_termination_date+1
          ,P_DATETRACK_MODE               => l_update_mode);
  --
      end loop;
   end if; -- if l_atd_changed
--
-- Now handle changes of Leaving Reason
--
-- If the Leaving Reason changes and ATD is not changing
-- the Leaving Reason is not null then default the Leaving Reason onto
-- the Assignment (SCL.SEGMENT4)
--
-- The record that will be updated will be the one that ends on ATD.
--
-- For this to be possible there must be the same lookup code as the Leaving
-- Reason in FR_ENDING_REASON
--
-- If such values do not exist then a NULL will be copied onto the SCL
--
-- N.B. This processing occurs only when ATD is set (i.e. a change of leaving
-- reason after termination )
-- It is therefore safe to assume that there will be  Assignment
-- records ending on the ATD. These records will have a datetrack CORRECTION.
--
hr_utility.set_location(l_proc,30);
   if p_actual_termination_date is not null and
   (not l_atd_changed) and l_leaving_reason_changed then
--
      correct_assignment(p_period_of_service_id
                        ,p_actual_termination_date
                        ,p_leaving_reason);
   end if;
--
-- Process contracts ending on Actual Termination Date - set End Reason
--
-- If the Leaving Reason changes or ATD changes and
-- the Leaving Reason is not null then default the Leaving Reason onto
-- the Contract (END_REASON)
--
-- The record that will be updated will be the one that ends on ATD.
--
-- For this to be possible there must be the same lookup code as the Leaving
-- Reason in CONTRACT_END_REASON
--
-- If such values do not exist then a NULL will be copied onto the contract
--
-- N.B. This processing occurs only when ATD is set (i.e. a change of leaving
-- reason after termination )
-- It is therefore safe to assume that there will be  Contract
-- records ending on the ATD. These records will have a datetrack CORRECTION.
--
   if p_actual_termination_date is not null and
   ((l_atd_changed and p_leaving_reason is not null) or
    (l_leaving_reason_changed )) then
hr_utility.set_location(l_proc,40);
      if p_leaving_reason is null or
       not validate_leaving_reason('CONTRACT_END_REASON',p_leaving_reason) then
         l_leaving_reason := null;
      else
         l_leaving_reason := p_leaving_reason;
      end if;
      --
      l_effective_date := p_actual_termination_date;
      for c in c_get_ctr loop
         if p_actual_termination_date = c.effective_end_date then
hr_utility.trace(c.contract_id);
            l_object_version_number := c.object_version_number;
            hr_contract_api.update_contract
            (P_VALIDATE                     => FALSE
            ,P_CONTRACT_ID                  => c.contract_id
            ,P_EFFECTIVE_START_DATE         => l_effective_start_date
            ,P_EFFECTIVE_END_DATE           => l_effective_end_date
            ,P_OBJECT_VERSION_NUMBER        => l_object_version_number
            ,P_PERSON_ID                    => c.person_id
            ,P_REFERENCE                    => c.reference
            ,P_TYPE                         => c.type
            ,P_STATUS                       => c.status
            ,P_END_REASON                   => l_leaving_reason
            ,P_EFFECTIVE_DATE               => p_actual_termination_date
            ,P_DATETRACK_MODE               => 'CORRECTION');
         end if; -- p_actual_termination_date = c.effective_end_date
      end loop;
   end if; -- if p_actual_termination_date is not null
--
-- Now handle creation of Last Day Worked Element Entry
-- The element should be created if ATD is not null and LWD is not null
-- and either LWD has been updated or termination is taking place.
--
hr_utility.set_location(l_proc,50);
  if p_actual_termination_date is not null
  and l_last_day_worked is not null
  and (l_lwd_changed or l_atd_changed) then
           last_day_worked_entry(l_last_day_worked
                                ,p_actual_termination_date);
  end if; -- if p_actual_termination_date is not null
--
hr_utility.set_location(l_proc,60);
end termination;
--
procedure reverse
(p_period_of_service_id number
,p_actual_termination_date date
,p_leaving_reason varchar2) is
--
l_proc varchar2(72) := g_package||'.reverse';
--
l_object_version_number number;
l_concatenated_segments varchar2(2000);
l_soft_coding_keyflex_id number;
l_comment_id  number;
l_effective_start_date date;
l_effective_end_date date;
l_no_managers_warning boolean;
l_other_manager_warning boolean;
l_status varchar2(30);
--
l_effective_date date;
--
cursor c_get_asg is
select a.object_version_number
,      a.assignment_id
,      a.soft_coding_keyflex_id
,      scl.segment2
,      decode(effective_end_date
             ,p_actual_termination_date,p_actual_termination_date
             ,p_actual_termination_date+1) effective_date
from per_all_assignments_f a
,    hr_soft_coding_keyflex scl
where period_of_service_id = p_period_of_service_id
and   (effective_end_date = p_actual_termination_date
   or  effective_start_date = p_actual_termination_date+1
   or   (p_actual_termination_date >= effective_start_date and
         effective_end_date = to_date('47121231','YYYYMMDD'))
      )
and   a.soft_coding_keyflex_id = scl.soft_coding_keyflex_id;
--
cursor c_get_ctr1 is
select contract_id
,      person_id
,      object_version_number
,      reference
,      type
,      status
,effective_start_date
,effective_end_date
from    per_contracts_f c
where  person_id =
(select person_id
 from per_periods_of_service
 where period_of_service_id = p_period_of_service_id)
and p_actual_termination_date = effective_end_date;
--
cursor c_get_ctr2 (p_contract_id number
                   ,p_effective_date date) is
select contract_id
,      person_id
,      object_version_number
,      reference
,      type
,      status
,effective_start_date
,effective_end_date
from    per_contracts_f c
where contract_id = p_contract_id
and   effective_start_date = p_effective_date;
--
ctr2 c_get_ctr2%rowtype;
--
begin
hr_utility.set_location(l_proc,10);
   initiate(p_period_of_service_id);
--
-- On reversing a terination update the assignment record that ended
-- at ATD to set the ending reason to NULL
--
   for a in c_get_asg loop
      l_object_version_number := a.object_version_number;
      hr_assignment_api.update_emp_asg
     (P_VALIDATE                     => FALSE
     ,P_EFFECTIVE_DATE               => a.effective_date
     ,P_DATETRACK_UPDATE_MODE        => 'CORRECTION'
     ,P_ASSIGNMENT_ID                => a.assignment_id
     ,P_OBJECT_VERSION_NUMBER        => l_object_version_number
     ,P_SEGMENT2                     => a.segment2
     ,P_SEGMENT4                     => null
     ,P_CONCATENATED_SEGMENTS        => l_concatenated_segments
     ,P_SOFT_CODING_KEYFLEX_ID       => l_soft_coding_keyflex_id
     ,P_COMMENT_ID                   => l_comment_id
     ,P_EFFECTIVE_START_DATE         => l_effective_start_date
     ,P_EFFECTIVE_END_DATE           => l_effective_end_date
     ,P_NO_MANAGERS_WARNING          => l_no_managers_warning
     ,P_OTHER_MANAGER_WARNING        => l_other_manager_warning);
   end loop;
hr_utility.set_location(l_proc,20);
/*
--
-- On reversing a terination update the contract record that started
-- on the day after ATD, set status back to Active
--
   l_effective_date := p_actual_termination_date + 1;
   for c in c_get_ctr loop
      l_object_version_number := c.object_version_number;
      if c.effective_start_date = l_effective_date then
--
-- Find the status of the previous contract, if found set it on the
-- contract record starting on ATD+1
--
         open c_get_status(c.contract_id,c.effective_start_date-1);
         fetch c_get_status into l_status;
         if c_get_status%found then
            close c_get_status;
            --
            hr_contract_api.update_contract
            (P_VALIDATE                     => FALSE
            ,P_CONTRACT_ID                  => c.contract_id
            ,P_EFFECTIVE_START_DATE         => l_effective_start_date
            ,P_EFFECTIVE_END_DATE           => l_effective_end_date
            ,P_OBJECT_VERSION_NUMBER        => l_object_version_number
            ,P_PERSON_ID                    => c.person_id
            ,P_REFERENCE                    => c.reference
            ,P_TYPE                         => c.type
            ,P_STATUS                       => l_status
            ,P_END_REASON                   => null
            ,P_EFFECTIVE_DATE               => l_effective_date
            ,P_DATETRACK_MODE               => 'CORRECTION');
        else
            close c_get_status;
        end if;
      end if; -- if c.effective_start_date = l_effective_date
   end loop;
hr_utility.set_location(l_proc,30);
*/
--
--
-- On reversing a terination update the contract record that ended
-- at ATD to set the ending reason to NULL
--
   for c in c_get_ctr1 loop
      l_object_version_number := c.object_version_number;
      hr_contract_api.update_contract
      (P_VALIDATE                     => FALSE
      ,P_CONTRACT_ID                  => c.contract_id
      ,P_EFFECTIVE_START_DATE         => l_effective_start_date
      ,P_EFFECTIVE_END_DATE           => l_effective_end_date
      ,P_OBJECT_VERSION_NUMBER        => l_object_version_number
      ,P_PERSON_ID                    => c.person_id
      ,P_REFERENCE                    => c.reference
      ,P_TYPE                         => c.type
      ,P_STATUS                       => c.status
      ,P_END_REASON                   => null
      ,P_EFFECTIVE_DATE               => p_actual_termination_date
      ,P_DATETRACK_MODE               => 'CORRECTION');
      --
      l_status := c.status;
      --
--
-- On reversing a terination update the contract record that started
-- on the day after ATD, set status back to Active
--
      open c_get_ctr2(c.contract_id,p_actual_termination_date+1);
      fetch c_get_ctr2 into ctr2;
      if c_get_ctr2%found then
         close c_get_ctr2;
         --
         l_object_version_number := ctr2.object_version_number;
         hr_contract_api.update_contract
         (P_VALIDATE                     => FALSE
         ,P_CONTRACT_ID                  => ctr2.contract_id
         ,P_EFFECTIVE_START_DATE         => l_effective_start_date
         ,P_EFFECTIVE_END_DATE           => l_effective_end_date
         ,P_OBJECT_VERSION_NUMBER        => l_object_version_number
         ,P_PERSON_ID                    => ctr2.person_id
         ,P_REFERENCE                    => ctr2.reference
         ,P_TYPE                         => ctr2.type
         ,P_STATUS                       => c.status
         ,P_END_REASON                   => null
         ,P_EFFECTIVE_DATE               => p_actual_termination_date+1
         ,P_DATETRACK_MODE               => 'CORRECTION');
      else
         close c_get_ctr2;
      end if;
   end loop;
hr_utility.set_location(l_proc,40);
--
-- Delete the FR_LAST_DAY_WORKED element entry that exists on ATD
--
   last_day_worked_entry(null
                        ,p_actual_termination_date);

hr_utility.set_location(l_proc,50);
end reverse;
--

FUNCTION npil_earnings_base_12months (p_assignment_id in Number,
                                                p_last_day_worked in Date) Return Number
IS
l_bal_date_to Date;
l_bal_date_from Date;
l_rolling_balance Number;
BEGIN
     -- Get the last day of the month prior to last working day
     l_bal_date_to := LAST_DAY(ADD_MONTHS(p_last_day_worked,-1)) ;
     -- function calculates over last 12 months
     -- 1st day of 12 calendar months prior to above date
     l_bal_date_from := TRUNC(ADD_MONTHS(l_bal_date_to+1,-12), 'MONTH');
     -- Get rolling balances
     l_rolling_balance := PAY_FR_GENERAL.FR_ROLLING_BALANCE
                                            (p_assignment_id,
                                             'FR_NOTICE_PERIOD_IN_LIEU_EARNINGS_BASE',
                                             l_bal_date_from,
                                             l_bal_date_to);

     RETURN l_rolling_balance;
END;

end per_fr_termination;

/
