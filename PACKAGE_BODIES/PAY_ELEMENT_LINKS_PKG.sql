--------------------------------------------------------
--  DDL for Package Body PAY_ELEMENT_LINKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ELEMENT_LINKS_PKG" as
/* $Header: pyeli.pkb 120.2.12010000.2 2008/08/06 07:09:30 ubhat ship $ */
/*===========================================================================+
 |               copyright (c) 1993 oracle corporation                       |
 |                  redwood shores, california, usa                          |
 |                       all rights reserved.                                |
 +===========================================================================*/
--
--
/*
Name
        Element Links Table Handler
Purpose
        To act as an interface between forms and the Element Links entity
History
        16-MAR-1994     N Simpson       Created
        29-MAR-1994     N Simpson       Amended element_in_distribution_set to
                                        restrict cursor by business group/
                                        legislation code
        22-JUN-1994     N Simpson       Fixes to G908 unit test bugs
  40.5  04-OCT-1994     R Fine          Renamed called package from
                                        assignment_link_usages_pkg to
                                        pay_asg_link_usages_pkg
        25-Oct-1994     N Simpson       Fixed G1355 by adding check to
                                        check_deletion_allowed to prevent
                                        deletion if balance adjustment entries
                                        exist outside the life of the link
  40.7  24-NOV-1994     R Fine          Suppressed index on business_group_id
  40.9  22-MAR-1995     N Simpson       Modified delete_row to cascade
                                        deletion of children differently
                                        according to the datetrack mode.
                                        See comments within that
                                        procedure.
  40.10 22-MAR-1995     N Simpson       Removed trace_on/off calls
  40.11 05-MAR-1997     J Alloun        Changed all occurances of system.dual
                                        to sys.dual for next release requirements.
  40.12 ??
  40.13 01-JUN-1997     M Lisiecki      Bug 481143. Changed message
                                        PAY_6465_LINK_NO_COST_UPD1 to more
                                        generic PAY_52151_ENTRIES_EXIST.
  40.14 02-JUN-1997     M Lisiecki      Changed 52151 to 52153 as 51 already
                                        existed.
 110.3  10-FEB-1999     M Reid          809540: Added segment19 to link test
                                        as it was missing.
 115.2  27-APR-1999     S Billing       874781,
                                        pay_element_links_pkg.update_row(),
                                        if updating an element link row with
                                        non-criteria information
                                        (ie. Qualifying Conditions), then the
                                        EED of the updated record or the
                                        newly created record should not exceed
                                        the EED of the original element link row
                                        update
 115.4 10-NOV-2000     RThirlby         Bug 1490304 Updated procedure
                                        check_deletion_allowed, so that cursor
                                        csr_balance_adjustments only gets
                                        called if p_delete_mode in DELETE or
                                        ZAP.
 115.5 27-APR-2001     DSaxby           Fix for 1755379.  Removed the erroneous
                                        close of the csr_balance_adjustments
                                        cursor in the check_deletion_allowed
                                        procedure.
 115.6 15-NOV-2002     ALogue           Performance fix for csr_entries in
                                        CHECK_DELETION_ALLOWED. Bug 2667222.
 115.7 03-DEC-2002     ALogue           dbdrv lines.
 115.8 20-MAY-2005     SuSivasu         Only update the last date tracked record
                                        with the end of time for the case of
                                        DELETE_NEXT_CHANGE DT mode.
 115.9 20-MAY-2005     SuSivasu         Fixed NOCOPY and GSCC issues.
 115.10 26-SEP-2006    THabara          Batch Element Link support. Bug 5512101.
                                        Modified cascade_deletion, update_row,
                                        check_deletion_allowed and
                                        last_exclusive_date.
 115.11 14-SEP-2006    THabara          Added function pay_basis_exists.
                                        Added pay basis check to insert_row.
 115.12 06-FEB-2008    salogana         Commented the pay_basis_exists
                                        check as the customer doesnt require
					this validation ( BUG NO : 6764215 ).
                                                                        */
--------------------------------------------------------------------------------
-- Declare global package variables and constants.
--
c_end_of_time   constant date   := hr_general.end_of_time;
g_dummy         number(1);
--------------------------------------------------------------------------------
procedure CASCADE_INSERTION (
--
--******************************************************************************
--* This procedure inserts link input values when an element link is
--* created. It will also insert assignment link usages.
--******************************************************************************
--
-- Parameters:
--
         p_element_link_id              number,
         p_element_type_id              number,
         p_effective_start_date         date,
         p_effective_end_date           date,
         p_people_group_id              number,
         p_costable_type                varchar2,
         p_business_group_id            number  ) is
--
begin
--
hr_utility.set_location('PAY_ELEMENT_LINKS_PKG.CASCADE_INSERTION', 1);
--
pay_link_input_values_pkg.create_link_input_value(
--
        p_element_link_id,
        p_costable_type,
        p_effective_start_date,
        p_effective_end_date,
        p_element_type_id);
--
hr_utility.set_location('PAY_ELEMENT_LINKS_PKG.CASCADE_INSERTION', 2);
--
pay_asg_link_usages_pkg.insert_alu(
--
        p_business_group_id,
        p_people_group_id,
        p_element_link_id,
        p_effective_start_date,
        p_effective_end_date);
--
end cascade_insertion;
--------------------------------------------------------------------------------
procedure CASCADE_DELETION(
--
--******************************************************************************
--* Cascades the deletion of an element link to its child entities.
--******************************************************************************
--
-- Parameters:
--
        p_element_link_id       number,
        p_business_group_id     number,
        p_people_group_id       number,
        p_delete_mode           varchar2,
        p_effective_start_date  date,
        p_effective_end_date    date,
        p_session_date          date,
        p_validation_start_date date,
        p_validation_end_date   date) is
--
cursor csr_links_entries is
        select  element_entry_id
        from    pay_element_entries_f
        where   element_link_id = p_element_link_id
        and     p_session_date between effective_start_date
                                and effective_end_date;
--
cursor csr_all_inputs_for_link is
        select  rowid, pay_link_input_values_f.*
        from    pay_link_input_values_f
        where   element_link_id = p_element_link_id
        for update;
--
begin
--
hr_utility.set_location('PAY_ELEMENT_LINKS_PKG.CASCADE_DELETION', 1);
--
for fetched_entry in csr_links_entries LOOP
--
  hr_entry_api.delete_element_entry (
--
        p_delete_mode,
        p_session_date,
        fetched_entry.element_entry_id);
--
end loop;
--
hr_utility.set_location('PAY_ELEMENT_LINKS_PKG.CASCADE_DELETION', 2);
--
pay_asg_link_usages_pkg.cascade_link_deletion (
--
        p_element_link_id,
        p_business_group_id,
        p_people_group_id,
        p_delete_mode,
        p_effective_start_date,
        p_effective_end_date,
        p_validation_start_date,
        p_validation_end_date);
--
-- Bug 5512101. Batch Element Link support.
-- Delete the object status record if the delete mode is ZAP.
--
if p_delete_mode = 'ZAP' then
  pay_batch_object_status_pkg.delete_object_status
    (p_object_type                  => 'EL'
    ,p_object_id                    => p_element_link_id
    ,p_payroll_action_id            => null
    );
end if;
--
hr_utility.set_location('PAY_ELEMENT_LINKS_PKG.CASCADE_DELETION', 3);
--
<<REMOVE_ORPHANED_INPUT_VALUES>>
--
FOR fetched_input_value in csr_all_inputs_for_link LOOP
--
-- Delete input value if in ZAP mode
-- Delete input value if it is in the future and in DELETE mode
--
 if p_delete_mode = 'ZAP'
    or (p_delete_mode = 'DELETE'
        and fetched_input_value.effective_start_date > p_session_date ) then
--
    delete from pay_link_input_values_f
    where current of csr_all_inputs_for_link;
--
  -- For date effective deletes, shut down the input value by ensuring its end
  -- date matches that of its closed parent
--
  elsif p_delete_mode = 'DELETE'
    and p_session_date  between fetched_input_value.effective_start_date
                        and     fetched_input_value.effective_end_date then
--
    update pay_link_input_values_f
    set effective_end_date = p_session_date
    where current of csr_all_inputs_for_link;
--
  -- For delete next changes when there are no future rows for the link,
  -- extend the input value's end date to the end of time to match the action
  -- which will be performed on the parent
--
  elsif p_delete_mode = 'DELETE_NEXT_CHANGE'
    and p_validation_end_date = hr_general.end_of_time then
--
    update pay_link_input_values_f
    set effective_end_date = c_end_of_time
    where --current of csr_all_inputs_for_link
      rowid = fetched_input_value.rowid
      and not exists
          (select null
             from pay_link_input_values_f pliv
            where pliv.element_link_id = fetched_input_value.element_link_id
              and pliv.input_value_id = fetched_input_value.input_value_id
              and pliv.effective_start_date > fetched_input_value.effective_start_date);
--
  end if;
  --
end loop remove_orphaned_input_values;
--
hr_utility.set_location('PAY_ELEMENT_LINKS_PKG.CASCADE_DELETION', 4);
--
end cascade_deletion;
--------------------------------------------------------------------------------
function LINK_END_DATE (p_link_id number) return date is
--
--******************************************************************************
--* Returns the end date of the Link.
--******************************************************************************
v_link_end_date date;
--
cursor csr_link is
        select max(effective_end_date)
        from    pay_element_links_f
        where   element_link_id = p_link_id;
--
begin
open csr_link;
fetch csr_link into v_link_end_date;
close csr_link;
return v_link_end_date;
end link_end_date;
--------------------------------------------------------------------------------
procedure insert_row(p_rowid                        in out nocopy varchar2,
                     p_element_link_id              in out nocopy number,
                     p_effective_start_date                date,
                     p_effective_end_date           in out nocopy date,
                     p_payroll_id                          number,
                     p_job_id                              number,
                     p_position_id                         number,
                     p_people_group_id                     number,
                     p_cost_allocation_keyflex_id          number,
                     p_organization_id                     number,
                     p_element_type_id                     number,
                     p_location_id                         number,
                     p_grade_id                            number,
                     p_balancing_keyflex_id                number,
                     p_business_group_id                   number,
                     p_legislation_code                    varchar2,
                     p_element_set_id                      number,
                     p_pay_basis_id                        number,
                     p_costable_type                       varchar2,
                     p_link_to_all_payrolls_flag           varchar2,
                     p_multiply_value_flag                 varchar2,
                     p_standard_link_flag                  varchar2,
                     p_transfer_to_gl_flag                 varchar2,
                     p_comment_id                          number,
                     p_employment_category                 varchar2,
                     p_qualifying_age                      number,
                     p_qualifying_length_of_service        number,
                     p_qualifying_units                    varchar2,
                     p_attribute_category                  varchar2,
                     p_attribute1                          varchar2,
                     p_attribute2                          varchar2,
                     p_attribute3                          varchar2,
                     p_attribute4                          varchar2,
                     p_attribute5                          varchar2,
                     p_attribute6                          varchar2,
                     p_attribute7                          varchar2,
                     p_attribute8                          varchar2,
                     p_attribute9                          varchar2,
                     p_attribute10                         varchar2,
                     p_attribute11                         varchar2,
                     p_attribute12                         varchar2,
                     p_attribute13                         varchar2,
                     p_attribute14                         varchar2,
                     p_attribute15                         varchar2,
                     p_attribute16                         varchar2,
                     p_attribute17                         varchar2,
                     p_attribute18                         varchar2,
                     p_attribute19                         varchar2,
                     p_attribute20                         varchar2) is
cursor csr_new_rowid is
        select  rowid
        from    pay_element_links_f
        where   element_link_id         = p_element_link_id
        and     effective_start_date    = p_effective_start_date
        and     effective_end_date      = p_effective_end_date;
--
cursor csr_next_ID is
        select  pay_element_links_s.nextval
        from sys.dual;
--
begin
--
hr_utility.set_location ('PAY_ELEMENT_LINKS_PKG.INSERT_ROW',1);
--
if p_element_link_id is null then
  open csr_next_ID;
  fetch csr_next_ID into p_element_link_id;
  close csr_next_ID;
end if;
--
if p_costable_type = 'D' and pay_element_links_pkg.element_in_distribution_set (
        p_element_type_id,
        p_business_group_id,
        p_legislation_code) then

  hr_utility.set_message(801,'PAY_6462_LINK_DIST_IN_DIST');
  hr_utility.raise_error;

end if;
--

/* commented the below block for bug no : 6764215

if p_standard_link_flag = 'Y' and
   pay_basis_exists(p_element_type_id, p_business_group_id) then

  hr_utility.set_message(801,'PAY_33093_LINK_NO_PAY_BASIS');
  hr_utility.raise_error;
end if;

*/
--
insert into pay_element_links_f(
--
          element_link_id,
          effective_start_date,
          effective_end_date,
          payroll_id,
          job_id,
          position_id,
          people_group_id,
          cost_allocation_keyflex_id,
          organization_id,
          element_type_id,
          location_id,
          grade_id,
          balancing_keyflex_id,
          business_group_id,
          element_set_id,
          pay_basis_id,
          costable_type,
          link_to_all_payrolls_flag,
          multiply_value_flag,
          standard_link_flag,
          transfer_to_gl_flag,
          comment_id,
          employment_category,
          qualifying_age,
          qualifying_length_of_service,
          qualifying_units,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute16,
          attribute17,
          attribute18,
          attribute19,
          attribute20)
values (
          p_element_link_id,
          p_effective_start_date,
          p_effective_end_date,
          p_payroll_id,
          p_job_id,
          p_position_id,
          p_people_group_id,
          p_cost_allocation_keyflex_id,
          p_organization_id,
          p_element_type_id,
          p_location_id,
          p_grade_id,
          p_balancing_keyflex_id,
          p_business_group_id,
          p_element_set_id,
          p_pay_basis_id,
          p_costable_type,
          p_link_to_all_payrolls_flag,
          p_multiply_value_flag,
          p_standard_link_flag,
          p_transfer_to_gl_flag,
          p_comment_id,
          p_employment_category,
          p_qualifying_age,
          p_qualifying_length_of_service,
          p_qualifying_units,
          p_attribute_category,
          p_attribute1,
          p_attribute2,
          p_attribute3,
          p_attribute4,
          p_attribute5,
          p_attribute6,
          p_attribute7,
          p_attribute8,
          p_attribute9,
          p_attribute10,
          p_attribute11,
          p_attribute12,
          p_attribute13,
          p_attribute14,
          p_attribute15,
          p_attribute16,
          p_attribute17,
          p_attribute18,
          p_attribute19,
          p_attribute20);
--
open csr_new_rowid;
fetch csr_new_rowid into p_rowid;
if (csr_new_rowid%notfound) then
  close csr_new_rowid;
  raise no_data_found;
end if;
close csr_new_rowid;
--
cascade_insertion (
        p_element_link_id,
        p_element_type_id,
        p_effective_start_date,
        p_effective_end_date,
        p_people_group_id,
        p_costable_type,
        p_business_group_id);
--
end insert_row;
-------------------------------------------------------------------------------
procedure lock_row(p_rowid                                 varchar2,
                   p_element_link_id                       number,
                   p_effective_start_date                  date,
                   p_effective_end_date                    date,
                   p_payroll_id                            number,
                   p_job_id                                number,
                   p_position_id                           number,
                   p_people_group_id                       number,
                   p_cost_allocation_keyflex_id            number,
                   p_organization_id                       number,
                   p_element_type_id                       number,
                   p_location_id                           number,
                   p_grade_id                              number,
                   p_balancing_keyflex_id                  number,
                   p_business_group_id                     number,
                   p_element_set_id                        number,
                   p_pay_basis_id                          number,
                   p_costable_type                         varchar2,
                   p_link_to_all_payrolls_flag             varchar2,
                   p_multiply_value_flag                   varchar2,
                   p_standard_link_flag                    varchar2,
                   p_transfer_to_gl_flag                   varchar2,
                   p_comment_id                            number,
                   p_employment_category                   varchar2,
                   p_qualifying_age                        number,
                   p_qualifying_length_of_service          number,
                   p_qualifying_units                      varchar2,
                   p_attribute_category                    varchar2,
                   p_attribute1                            varchar2,
                   p_attribute2                            varchar2,
                   p_attribute3                            varchar2,
                   p_attribute4                            varchar2,
                   p_attribute5                            varchar2,
                   p_attribute6                            varchar2,
                   p_attribute7                            varchar2,
                   p_attribute8                            varchar2,
                   p_attribute9                            varchar2,
                   p_attribute10                           varchar2,
                   p_attribute11                           varchar2,
                   p_attribute12                           varchar2,
                   p_attribute13                           varchar2,
                   p_attribute14                           varchar2,
                   p_attribute15                           varchar2,
                   p_attribute16                           varchar2,
                   p_attribute17                           varchar2,
                   p_attribute18                           varchar2,
                   p_attribute19                           varchar2,
                   p_attribute20                           varchar2) is
--
cursor csr_locked_row is
        select  *
        from    pay_element_links_f
        where   rowid = p_rowid
        for update of element_link_id NOWAIT;
--
locked_row csr_locked_row%rowtype;
--
begin
--
hr_utility.set_location ('PAY_ELEMENT_LINKS_PKG.LOCK_ROW',1);
--
open csr_locked_row;
fetch csr_locked_row into locked_row;
if csr_locked_row%notfound then
  close csr_locked_row;
  raise no_data_found;
end if;
close csr_locked_row;
--
  if (((locked_row.element_link_id = p_element_link_id)
           or ((locked_row.element_link_id is null)
               and (p_element_link_id is null)))
      and ((locked_row.effective_start_date = p_effective_start_date)
           or ((locked_row.effective_start_date is null)
               and (p_effective_start_date is null)))
      and ((locked_row.effective_end_date = p_effective_end_date)
           or ((locked_row.effective_end_date is null)
               and (p_effective_end_date is null)))
      and ((locked_row.payroll_id = p_payroll_id)
           or ((locked_row.payroll_id is null)
               and (p_payroll_id is null)))
      and ((locked_row.job_id = p_job_id)
           or ((locked_row.job_id is null)
               and (p_job_id is null)))
      and ((locked_row.position_id = p_position_id)
           or ((locked_row.position_id is null)
               and (p_position_id is null)))
      and ((locked_row.people_group_id = p_people_group_id)
           or ((locked_row.people_group_id is null)
               and (p_people_group_id is null)))
      and ((locked_row.cost_allocation_keyflex_id = p_cost_allocation_keyflex_id)
           or ((locked_row.cost_allocation_keyflex_id is null)
               and (p_cost_allocation_keyflex_id is null)))
      and (   (locked_row.organization_id = p_organization_id)
           or ((locked_row.organization_id is null)
               and (p_organization_id is null)))
      and (   (locked_row.element_type_id = p_element_type_id)
           or ((locked_row.element_type_id is null)
               and (p_element_type_id is null)))
      and (   (locked_row.location_id = p_location_id)
           or ((locked_row.location_id is null)
               and (p_location_id is null)))
      and (   (locked_row.grade_id = p_grade_id)
           or ((locked_row.grade_id is null)
               and (p_grade_id is null)))
      and (   (locked_row.balancing_keyflex_id = p_balancing_keyflex_id)
           or ((locked_row.balancing_keyflex_id is null)
               and (p_balancing_keyflex_id is null)))
      and (   (locked_row.business_group_id = p_business_group_id)
           or ((locked_row.business_group_id is null)
               and (p_business_group_id is null)))
      and (   (locked_row.element_set_id = p_element_set_id)
           or (    (locked_row.element_set_id is null)
               and (p_element_set_id is null)))
      and (   (locked_row.pay_basis_id = p_pay_basis_id)
           or (    (locked_row.pay_basis_id is null)
               and (p_pay_basis_id is null)))
      and (   (locked_row.costable_type = p_costable_type)
           or (    (locked_row.costable_type is null)
               and (p_costable_type is null)))
      and (   (locked_row.link_to_all_payrolls_flag = p_link_to_all_payrolls_flag)
           or (    (locked_row.link_to_all_payrolls_flag is null)
               and (p_link_to_all_payrolls_flag is null)))
      and (   (locked_row.multiply_value_flag = p_multiply_value_flag)
           or (    (locked_row.multiply_value_flag is null)
               and (p_multiply_value_flag is null)))
      and (   (locked_row.standard_link_flag = p_standard_link_flag)
           or (    (locked_row.standard_link_flag is null)
               and (p_standard_link_flag is null)))
      and (   (locked_row.transfer_to_gl_flag = p_transfer_to_gl_flag)
           or (    (locked_row.transfer_to_gl_flag is null)
               and (p_transfer_to_gl_flag is null)))
      and (   (locked_row.comment_id = p_comment_id)
           or (    (locked_row.comment_id is null)
               and (p_comment_id is null)))
      and (   (locked_row.employment_category = p_employment_category)
           or (    (locked_row.employment_category is null)
               and (p_employment_category is null)))
      and (   (locked_row.qualifying_age = p_qualifying_age)
           or (    (locked_row.qualifying_age is null)
               and (p_qualifying_age is null)))
      and ((locked_row.qualifying_length_of_service=p_qualifying_length_of_service)
           or (    (locked_row.qualifying_length_of_service is null)
               and (p_qualifying_length_of_service is null)))
      and (   (locked_row.qualifying_units = p_qualifying_units)
           or (    (locked_row.qualifying_units is null)
               and (p_qualifying_units is null)))
      and (   (locked_row.attribute_category = p_attribute_category)
           or (    (locked_row.attribute_category is null)
               and (p_attribute_category is null)))
      and (   (locked_row.attribute1 = p_attribute1)
           or (    (locked_row.attribute1 is null)
               and (p_attribute1 is null)))
      and (   (locked_row.attribute2 = p_attribute2)
           or (    (locked_row.attribute2 is null)
               and (p_attribute2 is null)))
      and (   (locked_row.attribute3 = p_attribute3)
           or (    (locked_row.attribute3 is null)
               and (p_attribute3 is null)))
      and (   (locked_row.attribute4 = p_attribute4)
           or (    (locked_row.attribute4 is null)
               and (p_attribute4 is null)))
      and (   (locked_row.attribute5 = p_attribute5)
           or (    (locked_row.attribute5 is null)
               and (p_attribute5 is null)))
      and (   (locked_row.attribute6 = p_attribute6)
           or (    (locked_row.attribute6 is null)
               and (p_attribute6 is null)))
      and (   (locked_row.attribute7 = p_attribute7)
           or (    (locked_row.attribute7 is null)
               and (p_attribute7 is null)))
      and (   (locked_row.attribute8 = p_attribute8)
           or (    (locked_row.attribute8 is null)
               and (p_attribute8 is null)))
      and (   (locked_row.attribute9 = p_attribute9)
           or (    (locked_row.attribute9 is null)
               and (p_attribute9 is null)))
      and (   (locked_row.attribute10 = p_attribute10)
           or (    (locked_row.attribute10 is null)
               and (p_attribute10 is null)))
      and (   (locked_row.attribute11 = p_attribute11)
           or (    (locked_row.attribute11 is null)
               and (p_attribute11 is null)))
      and (   (locked_row.attribute12 = p_attribute12)
           or (    (locked_row.attribute12 is null)
               and (p_attribute12 is null)))
      and (   (locked_row.attribute13 = p_attribute13)
           or (    (locked_row.attribute13 is null)
               and (p_attribute13 is null)))
      and (   (locked_row.attribute14 = p_attribute14)
           or (    (locked_row.attribute14 is null)
               and (p_attribute14 is null)))
      and (   (locked_row.attribute15 = p_attribute15)
           or (    (locked_row.attribute15 is null)
               and (p_attribute15 is null)))
      and (   (locked_row.attribute16 = p_attribute16)
           or (    (locked_row.attribute16 is null)
               and (p_attribute16 is null)))
      and (   (locked_row.attribute17 = p_attribute17)
           or (    (locked_row.attribute17 is null)
               and (p_attribute17 is null)))
      and (   (locked_row.attribute18 = p_attribute18)
           or (    (locked_row.attribute18 is null)
               and (p_attribute18 is null)))
      and (   (locked_row.attribute19 = p_attribute19)
           or (    (locked_row.attribute19 is null)
               and (p_attribute19 is null)))
      and (   (locked_row.attribute20 = p_attribute20)
           or (    (locked_row.attribute20 is null)
               and (p_attribute20 is null)))
          ) then
    return;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
end lock_row;
--------------------------------------------------------------------------------
procedure update_row(p_rowid                               varchar2,
                     p_element_link_id                     number,
                     p_effective_start_date                date,
                     p_effective_end_date           in out nocopy date,
                     p_payroll_id                          number,
                     p_job_id                              number,
                     p_position_id                         number,
                     p_people_group_id                     number,
                     p_cost_allocation_keyflex_id          number,
                     p_organization_id                     number,
                     p_element_type_id                     number,
                     p_location_id                         number,
                     p_grade_id                            number,
                     p_balancing_keyflex_id                number,
                     p_business_group_id                   number,
                     p_legislation_code                    varchar2,
                     p_element_set_id                      number,
                     p_pay_basis_id                        number,
                     p_costable_type                       varchar2,
                     p_link_to_all_payrolls_flag           varchar2,
                     p_multiply_value_flag                 varchar2,
                     p_standard_link_flag                  varchar2,
                     p_transfer_to_gl_flag                 varchar2,
                     p_comment_id                          number,
                     p_employment_category                 varchar2,
                     p_qualifying_age                      number,
                     p_qualifying_length_of_service        number,
                     p_qualifying_units                    varchar2,
                     p_attribute_category                  varchar2,
                     p_attribute1                          varchar2,
                     p_attribute2                          varchar2,
                     p_attribute3                          varchar2,
                     p_attribute4                          varchar2,
                     p_attribute5                          varchar2,
                     p_attribute6                          varchar2,
                     p_attribute7                          varchar2,
                     p_attribute8                          varchar2,
                     p_attribute9                          varchar2,
                     p_attribute10                         varchar2,
                     p_attribute11                         varchar2,
                     p_attribute12                         varchar2,
                     p_attribute13                         varchar2,
                     p_attribute14                         varchar2,
                     p_attribute15                         varchar2,
                     p_attribute16                         varchar2,
                     p_attribute17                         varchar2,
                     p_attribute18                         varchar2,
                     p_attribute19                         varchar2,
                     p_attribute20                         varchar2) is
--
begin
--
hr_utility.set_location ('PAY_ELEMENT_LINKS_PKG.UPDATE_ROW',1);
--
/*
p_effective_end_date := pay_element_links_pkg.max_end_date (
        p_element_type_id,
        p_element_link_id,
        p_effective_start_date,
        p_effective_end_date,
        p_organization_id,
        p_people_group_id,
        p_job_id,
        p_position_id,
        p_grade_id,
        p_location_id,
        p_link_to_all_payrolls_flag,
        p_payroll_id,
        p_employment_category,
        p_pay_basis_id,
        p_business_group_id);
*/
--
-- Bug 5512101. Batch Element Link support.
-- We need to lock the batch object status and ensure that the element
-- link is complete.
--
pay_batch_object_status_pkg.chk_complete_status
  (p_object_type                  => 'EL'
  ,p_object_id                    => p_element_link_id
  );

--
-- sbilling 874781,
-- pay_element_links_pkg.update_row(),
-- if updating an element link row with non-criteria information
-- (ie. Qualifying Conditions), then the EED
-- of the updated record or the newly created record should not exceed
-- the EED of the original element link row
-- update
--
p_effective_end_date :=
        least(
                p_effective_end_date,
                pay_element_links_pkg.max_end_date (
                        p_element_type_id,
                        p_element_link_id,
                        p_effective_start_date,
                        p_effective_end_date,
                        p_organization_id,
                        p_people_group_id,
                        p_job_id,
                        p_position_id,
                        p_grade_id,
                        p_location_id,
                        p_link_to_all_payrolls_flag,
                        p_payroll_id,
                        p_employment_category,
                        p_pay_basis_id,
                        p_business_group_id)
                );
hr_utility.trace ('|p_effective_end_date>' || p_effective_end_date || '<');


if p_costable_type = 'D'
and pay_element_links_pkg.element_in_distribution_set (
        p_element_type_id,
        p_business_group_id,
        p_legislation_code) then

  hr_utility.set_message(801,'PAY_6462_LINK_DIST_IN_DIST');
  hr_utility.raise_error;

end if;

update pay_element_links_f
set element_link_id                           =    p_element_link_id,
    effective_start_date                      =    p_effective_start_date,
    effective_end_date                        =    p_effective_end_date,
    payroll_id                                =    p_payroll_id,
    job_id                                    =    p_job_id,
    position_id                               =    p_position_id,
    people_group_id                           =    p_people_group_id,
    cost_allocation_keyflex_id                =    p_cost_allocation_keyflex_id,
    organization_id                           =    p_organization_id,
    element_type_id                           =    p_element_type_id,
    location_id                               =    p_location_id,
    grade_id                                  =    p_grade_id,
    balancing_keyflex_id                      =    p_balancing_keyflex_id,
    business_group_id                         =    p_business_group_id,
    element_set_id                            =    p_element_set_id,
    pay_basis_id                              =    p_pay_basis_id,
    costable_type                             =    p_costable_type,
    link_to_all_payrolls_flag                 =    p_link_to_all_payrolls_flag,
    multiply_value_flag                       =    p_multiply_value_flag,
    standard_link_flag                        =    p_standard_link_flag,
    transfer_to_gl_flag                       =    p_transfer_to_gl_flag,
    comment_id                                =    p_comment_id,
    employment_category                       =    p_employment_category,
    qualifying_age                            =    p_qualifying_age,
    qualifying_length_of_service              =    p_qualifying_length_of_service,
    qualifying_units                          =    p_qualifying_units,
    attribute_category                        =    p_attribute_category,
    attribute1                                =    p_attribute1,
    attribute2                                =    p_attribute2,
    attribute3                                =    p_attribute3,
    attribute4                                =    p_attribute4,
    attribute5                                =    p_attribute5,
    attribute6                                =    p_attribute6,
    attribute7                                =    p_attribute7,
    attribute8                                =    p_attribute8,
    attribute9                                =    p_attribute9,
    attribute10                               =    p_attribute10,
    attribute11                               =    p_attribute11,
    attribute12                               =    p_attribute12,
    attribute13                               =    p_attribute13,
    attribute14                               =    p_attribute14,
    attribute15                               =    p_attribute15,
    attribute16                               =    p_attribute16,
    attribute17                               =    p_attribute17,
    attribute18                               =    p_attribute18,
    attribute19                               =    p_attribute19,
    attribute20                               =    p_attribute20
  where rowid = p_rowid;
--
if sql%notfound then
  raise no_data_found;
end if;
--
end update_row;
--------------------------------------------------------------------------------
procedure delete_row(
--
        p_rowid                 varchar2,
        p_element_link_id       number,
        p_delete_mode           varchar2,
        p_session_date          date,
        p_validation_start_date date,
        p_validation_end_date   date,
        p_effective_start_date  date,
        p_business_group_id     number,
        p_people_group_id       number) is
--
v_effective_end_date    date;
--
begin
--
hr_utility.set_location ('PAY_ELEMENT_LINKS_PKG.DELETE_ROW',1);
--
check_deletion_allowed (        p_element_link_id,
                                p_delete_mode,
                                p_validation_start_date);
--
v_effective_end_date := pay_element_links_pkg.link_end_date (p_element_link_id);
--
-- Note that the cascade delete of any action other than PURGE/ZAP will
-- be done AFTER the deletion of the master record. This is due to a
-- quirk of datetrack in forms which means that up to the point of
-- deletion of a link, when not zapping, there will be TWO rows with the
-- same ID and overlapping in date-effective time. If any of the child
-- entities looks back up at the link table, it will return duplicate
-- rows and may fail with unhelpful system errors. By doing the cascade
-- after the deletion of the master, we ensure that the duplicate row
-- has been removed prior to the child deletions.
--
if p_delete_mode = 'ZAP' then
  --
  cascade_deletion (
        p_element_link_id       ,
        p_business_group_id,
        p_people_group_id,
        p_delete_mode           ,
        p_effective_start_date,
        v_effective_end_date,
        p_session_date,
        p_validation_start_date ,
        p_validation_end_date   );
  --
end if;
--
delete from pay_element_links_f
where  rowid = p_rowid;
--
if sql%notfound then
  raise no_data_found;
end if;
--
if p_delete_mode <> 'ZAP' then
  --
  cascade_deletion (
        p_element_link_id       ,
        p_business_group_id,
        p_people_group_id,
        p_delete_mode           ,
        p_effective_start_date,
        v_effective_end_date,
        p_session_date,
        p_validation_start_date ,
        p_validation_end_date   );
  --
end if;
--
end delete_row;
--------------------------------------------------------------------------------
function LAST_EXCLUSIVE_DATE (
--
--******************************************************************************
--* Returns the last date on which the link will be mutually exclusive with    *
--* other links for the same element type, or an error if no such date can be  *
--* achieved.                                                                  *
--******************************************************************************
--
-- Parameters are:
--
        p_element_type_id               number,
        p_element_link_id               number,
        p_validation_start_date         date,
        p_validation_end_date           date,
        p_organization_id               number,
        p_people_group_id               number,
        p_job_id                        number,
        p_position_id                   number,
        p_grade_id                      number,
        p_location_id                   number,
        p_payroll_id                    number,
        p_employment_category           varchar2,
        p_pay_basis_id                  number,
        p_business_group_id             number) return date is
--
cursor csr_other_links_for_element is
        -- Set of links for the same element as the link being tested
        select  link.effective_start_date,
                link.effective_end_date,
                link.organization_id,
                link.people_group_id,
                link.job_id,
                link.position_id,
                link.grade_id,
                link.location_id,
                link.link_to_all_payrolls_flag          PAYROLL_FLAG,
                link.payroll_id,
                link.employment_category,
                link.pay_basis_id,
                people_group.segment1,
                people_group.segment2,
                people_group.segment3,
                people_group.segment4,
                people_group.segment5,
                people_group.segment6,
                people_group.segment7,
                people_group.segment8,
                people_group.segment9,
                people_group.segment10,
                people_group.segment11,
                people_group.segment12,
                people_group.segment13,
                people_group.segment14,
                people_group.segment15,
                people_group.segment16,
                people_group.segment17,
                people_group.segment18,
                people_group.segment19,
                people_group.segment20,
                people_group.segment21,
                people_group.segment22,
                people_group.segment23,
                people_group.segment24,
                people_group.segment25,
                people_group.segment26,
                people_group.segment27,
                people_group.segment28,
                people_group.segment29,
                people_group.segment30
        from    pay_element_links_f     LINK,
                pay_people_groups       PEOPLE_GROUP
        where   link.people_group_id     = people_group.people_group_id(+)
        and     link.element_type_id     = p_element_type_id
        and     link.element_link_id    <> nvl(p_element_link_id,0)
        and     link.business_group_id + 0       = p_business_group_id
        and     link.effective_end_date >= p_validation_start_date
        --
        -- Batch element link support.
        --
        UNION ALL
        select  bel.effective_date effective_start_date,
                hr_general.end_of_time effective_end_date,
                bel.organization_id,
                bel.people_group_id,
                bel.job_id,
                bel.position_id,
                bel.grade_id,
                bel.location_id,
                bel.link_to_all_payrolls_flag          PAYROLL_FLAG,
                bel.payroll_id,
                bel.employment_category,
                bel.pay_basis_id,
                people_group.segment1,
                people_group.segment2,
                people_group.segment3,
                people_group.segment4,
                people_group.segment5,
                people_group.segment6,
                people_group.segment7,
                people_group.segment8,
                people_group.segment9,
                people_group.segment10,
                people_group.segment11,
                people_group.segment12,
                people_group.segment13,
                people_group.segment14,
                people_group.segment15,
                people_group.segment16,
                people_group.segment17,
                people_group.segment18,
                people_group.segment19,
                people_group.segment20,
                people_group.segment21,
                people_group.segment22,
                people_group.segment23,
                people_group.segment24,
                people_group.segment25,
                people_group.segment26,
                people_group.segment27,
                people_group.segment28,
                people_group.segment29,
                people_group.segment30
        from    pay_batch_element_links BEL,
                pay_people_groups       PEOPLE_GROUP
        where   bel.people_group_id     = people_group.people_group_id(+)
        and     bel.element_type_id     = p_element_type_id
        and     bel.batch_element_link_id <> nvl(p_element_link_id,0)
        and     bel.element_link_id     is null
        and     bel.business_group_id + 0       = p_business_group_id
        -- exclude the batch link that is currently processing.
        and     nvl(pay_batch_object_status_pkg.get_status
                      ('BEL',bel.batch_element_link_id),'U') <> 'P'
        order by effective_start_date;
--
cursor csr_my_people_group is
        -- Segments of people group for the link being tested
        select  *
        from pay_people_groups
        where people_group_id = p_people_group_id;
--
new_link        csr_my_people_group%rowtype;
v_last_exclusive_date   date;
--
function link_differs_on (p_existing_row        varchar2,
                                p_new_row       varchar2) return boolean is
        -- return TRUE if the two parameters differ and neither one is null
        begin
        return (p_existing_row <> p_new_row
                and p_existing_row is not null
                and p_new_row is not null);
        end link_differs_on;

BEGIN

hr_utility.set_location('PAY_ELEMENT_LINKS_PKG.LAST_EXCLUSIVE_DATE', 1);

open csr_my_people_group;
fetch csr_my_people_group into new_link;

-- Check for matching criteria on other links for this element.
-- The link criteria being tested are made up of the parameters and the
-- new_link record. If any of the link's criteria are matched in
-- another link for the same element, then the link being tested must be
-- given an end date just prior to the start date of the matching link. If this
-- cannot be done, then an error will occur. A match is PAY_ELEMENT_LINKS_PKGd as either
-- equality between the criteria items, or where one of the items is
-- unspecified.
-- NB It is more efficient to check for a non-match because a single
-- non-matching item will satisfy the exclusivity for the whole record, whilst
-- finding a match need not negate the exclusivity.

<<LINK_TEST>>
for existing_link in csr_other_links_for_element LOOP

  if NOT(  (link_differs_on (existing_link.organization_id, p_organization_id))
        or (link_differs_on (existing_link.job_id, p_job_id ))
        or (link_differs_on (existing_link.position_id, p_position_id))
        or (link_differs_on (existing_link.grade_id, p_grade_id))
        or (link_differs_on (existing_link.location_id, p_location_id))
        or (link_differs_on (existing_link.payroll_id, p_payroll_id))
        or (link_differs_on (existing_link.employment_category, p_employment_category))
        or (link_differs_on (existing_link.pay_basis_id,  p_pay_basis_id))
        or (link_differs_on (existing_link.segment1,  new_link.segment1))
        or (link_differs_on (existing_link.segment2,  new_link.segment2))
        or (link_differs_on (existing_link.segment3,  new_link.segment3))
        or (link_differs_on (existing_link.segment4,  new_link.segment4))
        or (link_differs_on (existing_link.segment5,  new_link.segment5))
        or (link_differs_on (existing_link.segment6,  new_link.segment6))
        or (link_differs_on (existing_link.segment7,  new_link.segment7))
        or (link_differs_on (existing_link.segment8,  new_link.segment8))
        or (link_differs_on (existing_link.segment9,  new_link.segment9))
        or (link_differs_on (existing_link.segment10, new_link.segment10))
        or (link_differs_on (existing_link.segment11, new_link.segment11))
        or (link_differs_on (existing_link.segment12, new_link.segment12))
        or (link_differs_on (existing_link.segment13, new_link.segment13))
        or (link_differs_on (existing_link.segment14, new_link.segment14))
        or (link_differs_on (existing_link.segment15, new_link.segment15))
        or (link_differs_on (existing_link.segment16, new_link.segment16))
        or (link_differs_on (existing_link.segment17, new_link.segment17))
        or (link_differs_on (existing_link.segment18, new_link.segment18))
        or (link_differs_on (existing_link.segment19, new_link.segment19))
        or (link_differs_on (existing_link.segment20, new_link.segment20))
        or (link_differs_on (existing_link.segment21, new_link.segment21))
        or (link_differs_on (existing_link.segment22, new_link.segment22))
        or (link_differs_on (existing_link.segment23, new_link.segment23))
        or (link_differs_on (existing_link.segment24, new_link.segment24))
        or (link_differs_on (existing_link.segment25, new_link.segment25))
        or (link_differs_on (existing_link.segment26, new_link.segment26))
        or (link_differs_on (existing_link.segment27, new_link.segment27))
        or (link_differs_on (existing_link.segment28, new_link.segment28))
        or (link_differs_on (existing_link.segment29, new_link.segment29))
        or (link_differs_on (existing_link.segment30, new_link.segment30)))
then
--
hr_utility.set_location ('PAY_ELEMENT_LINKS_PKG.last_exclusive_date',2);
--
    -- Set the end date to avoid clash; raise an error if that is not possible
    if (p_validation_start_date < existing_link.effective_start_date) then
--
hr_utility.set_location ('PAY_ELEMENT_LINKS_PKG.last_exclusive_date',3);
      v_last_exclusive_date := existing_link.effective_start_date - 1;
      exit LINK_TEST;   -- The cursor ordering ensures that the date is that
                -- of the chronologically first matching link
--
    else
--
      hr_utility.set_message(801,'PAY_6398_ELEMENT_NOT_MUT_EXCLU');
      hr_utility.raise_error;
--
    end if;
--
  end if;
--
end loop;
close csr_my_people_group;
--
if v_last_exclusive_date is null then   -- no matching criteria were found
  v_last_exclusive_date := c_end_of_time;
end if;
--
hr_utility.trace ('v_last_exclusive_date is '||v_last_exclusive_date);
--
return v_last_exclusive_date;
--
end last_exclusive_date;
--------------------------------------------------------------------------------
function MAX_END_DATE(
--
--******************************************************************************
--* Returns the latest allowable date for the effective end date of a link.    *
--* This is the latest of:                                                     *
--*     1.      The element type's last effective end date.                    *
--*     2.      The latest end date for a payroll associated with the link.    *
--*     3.      The day before the start date of another link which would      *
--*             have matching criteria for the same element.
--******************************************************************************
--
-- Parameters are:
--
        p_element_type_id               number,
        p_element_link_id               number,
        p_validation_start_date         date,
        p_validation_end_date           date,
        p_organization_id               number,
        p_people_group_id               number,
        p_job_id                        number,
        p_position_id                   number,
        p_grade_id                      number,
        p_location_id                   number,
        p_link_to_all_payrolls_flag     varchar2,
        p_payroll_id                    number,
        p_employment_category           varchar2,
        p_pay_basis_id                  number,
        p_business_group_id             number) return date is
--
v_max_payroll_date      date;
v_max_element_date      date;
--
cursor csr_named_element is
        -- Maximum end date for the named element type
        select  max(effective_end_date)
        from    pay_element_types_f
        where   element_type_id = p_element_type_id;
--
cursor csr_business_group_payrolls is
        -- Maximum end date for any payroll in the business group
        select  max(effective_end_date)
        from    pay_payrolls_f
        where   business_group_id + 0   = p_business_group_id;
--
cursor csr_named_payroll is
        -- Maximum end date for the payroll identified by the payroll ID
        select  max(effective_end_date)
        from    pay_payrolls_f
        where   payroll_id      = p_payroll_id;
begin
--
hr_utility.set_location ('PAY_ELEMENT_LINKS_PKG.MAX_END_DATE',1);
hr_utility.trace ('p_validation_start_date = '||p_validation_start_date);
hr_utility.trace ('p_validation_end_date = '||p_validation_end_date);
--
-- If there is a named payroll, then take its last end date; if the link is to
-- all payrolls, then take the latest end date from all payrolls in the
-- business group.
if p_link_to_all_payrolls_flag = 'Y' then
  open csr_business_group_payrolls;
  fetch csr_business_group_payrolls into v_max_payroll_date;
  close csr_business_group_payrolls;
--
elsif p_payroll_id is not null then
  open csr_named_payroll;
  fetch csr_named_payroll into v_max_payroll_date;
  close csr_named_payroll;
--
end if;
--
v_max_payroll_date := nvl(v_max_payroll_date, c_end_of_time);
--
open csr_named_element;
fetch csr_named_element into v_max_element_date;
close csr_named_element;
--
v_max_element_date := nvl(v_max_element_date, c_end_of_time);
--
hr_utility.trace ('v_max_element_date is '||v_max_element_date);
hr_utility.trace ('v_max_payroll_date is '||v_max_payroll_date);

return least (  v_max_payroll_date,
                v_max_element_date,
                last_exclusive_date (p_element_type_id,
                                        p_element_link_id,
                                        p_validation_start_date,
                                        p_validation_end_date,
                                        p_organization_id,
                                        p_people_group_id,
                                        p_job_id,
                                        p_position_id,
                                        p_grade_id,
                                        p_location_id,
                                        p_payroll_id,
                                        p_employment_category,
                                        p_pay_basis_id,
                                        p_business_group_id     ));
--
end max_end_date;
--------------------------------------------------------------------------------
function ELEMENT_IN_DISTRIBUTION_SET (
--******************************************************************************
--* Returns TRUE if the element is in a distribution set
--******************************************************************************

        p_element_type_id               number,
        p_business_group_id             number,
        p_legislation_code              varchar2) return boolean is

cursor csr_distribution_set is
        --
        -- Returns a row if the element is in a distribution set
        -- NB Because pay_element_set_members is a complex view it cannot
        -- restrict on business group id and so I must use this as part of the
        -- join to it.
        --
        select  1
        from    pay_element_set_members MEMBER,
                pay_element_sets        ELEMENT_SET
        where   element_set.element_set_id      = member.element_set_id
        and     member.element_type_id          = p_element_type_id
        and     element_set.element_set_type    = 'D'
        and     (element_set.business_group_id + 0
                                                = member.business_group_id + 0
                and element_set.business_group_id + 0 = p_business_group_id
                or (p_business_group_id is null
                        and element_set.legislation_code =
                        member.legislation_code
                        and element_set.legislation_code = p_legislation_code));

element_in_set  boolean;

begin

hr_utility.set_location('PAY_ELEMENT_LINKS_PKG.CHECK_DISTRIBUTION_SET', 1);

open csr_distribution_set;
fetch csr_distribution_set into g_dummy;
element_in_set := csr_distribution_set%found;
close csr_distribution_set;

return element_in_set;

end element_in_distribution_set;
--------------------------------------------------------------------------------
function ELEMENT_ENTRIES_EXIST (
--
--******************************************************************************
--* Returns TRUE if element entries already exist for this link                *
--******************************************************************************
--
-- Parameters are:
--
        p_element_link_id       number,
        p_error_if_true         boolean := FALSE) return boolean is
--
v_entries_exist boolean := FALSE;
--
cursor csr_entries is
        select  1
        from    pay_element_entries_f
        where   element_link_id = p_element_link_id;
begin
--
hr_utility.set_location('PAY_ELEMENT_LINKS_PKG.ELEMENT_ENTRIES_EXIST', 1);
--
open csr_entries;
fetch csr_entries into g_dummy;
if csr_entries%found and p_error_if_true then
  -- Bug 481143. Changed message 6465 to 52153.01-Jul-1997.mlisieck.
  hr_utility.set_message(801,'PAY_52153_ENTRIES_EXIST');
  hr_utility.raise_error;
end if;
v_entries_exist := csr_entries%found;
close csr_entries;
--
return v_entries_exist;
--
end element_entries_exist;
--------------------------------------------------------------------------------
function DATE_EFFECTIVELY_UPDATED (
--
--******************************************************************************
--* Returns TRUE if there exists more than one row with the same link ID       *
--******************************************************************************
--
-- Parameters are:
--
        p_element_link_id       number,
        p_rowid                 varchar2) return boolean is
--
v_updates_exist boolean := FALSE;
--
cursor csr_updates is
        select  1
        from    pay_element_links_f
        where   element_link_id  = p_element_link_id
        and     rowid           <> p_rowid;
--
begin
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.DATE_EFFECTIVELY_UPDATED',1);
--
open csr_updates;
fetch csr_updates into g_dummy;
v_updates_exist := csr_updates%found;
close csr_updates;
--
return v_updates_exist;
--
end date_effectively_updated;
--------------------------------------------------------------------------------
procedure CHECK_DELETION_ALLOWED (
--
--******************************************************************************
--* Checks to see if link may be deleted.                                      *
--******************************************************************************
--
-- Parameters:
--
        p_element_link_id       number,
        p_delete_mode           varchar2,
        p_validation_start_date date    ) is
--
-- Are there entries whose earliest start date is after the deletion date?
cursor csr_entries is
        select  1
        from    pay_element_entries_f ENTRY1
        where   entry1.element_link_id  = p_element_link_id
        and     not(entry1.effective_start_date     < p_validation_start_date);
--
-- Bug 1490304 - removed p_delete_mode from where clause.
--
cursor csr_balance_adjustments is
        select  1
        from    pay_element_entries_f BALANCE_ENTRY
        where   balance_entry.element_link_id = p_element_link_id
        and     balance_entry.effective_start_date > p_validation_start_date
       -- and     p_delete_mode in ('DELETE','ZAP')
        and     balance_entry.entry_type = 'B';
--
begin
--
hr_utility.set_location('PAY_ELEMENT_LINKS_PKG.CHECK_DELETION_ALLOWED', 10);
--
-- Bug 5512101. Changes for Batch Element Link support.
-- We need to ensure that the element link is complete
-- unless the delete mode is ZAP.
--
if p_delete_mode <> 'ZAP' then
  pay_batch_object_status_pkg.chk_complete_status
    (p_object_type                  => 'EL'
    ,p_object_id                    => p_element_link_id
    );
end if;


hr_utility.set_location('PAY_ELEMENT_LINKS_PKG.CHECK_DELETION_ALLOWED', 20);
--
-- Bug 1490304 - if p_delete_mode in DELETE or ZAP then open both cursors
-- else only open csr_entries.
--
IF p_delete_mode in ('DELETE','ZAP') THEN
  open  csr_entries;
  open  csr_balance_adjustments;
  fetch csr_entries into g_dummy;
  fetch csr_balance_adjustments into g_dummy;
    if csr_entries%found or csr_balance_adjustments%found then
      hr_utility.set_message(801,'HR_7134_LINK_NO_DEL_ENTRIES');
      hr_utility.raise_error;
    end if;
  close csr_entries;
  close csr_balance_adjustments;
ELSE
  open  csr_entries;
  fetch csr_entries into g_dummy;
    if csr_entries%found then
      hr_utility.set_message(801,'HR_7134_LINK_NO_DEL_ENTRIES');
      hr_utility.raise_error;
    end if;
  close csr_entries;
END IF;
end check_deletion_allowed;
--------------------------------------------------------------------------------
procedure CHECK_RELATIONSHIPS (
--
--******************************************************************************
--* Returns values used by forms to set item properties. The calls within this *
--* procedure could be used separately, but bundling them here reduces network *
--* traffic.                                                                   *
--******************************************************************************
--
-- Parameters are:
--
        p_element_link_id                       number,
        p_rowid                                 varchar2,
        p_date_effectively_updated      out     nocopy boolean,
        p_element_entries_exist         out     nocopy boolean ) is
--
begin
--
hr_utility.set_location ('pay_element_links_pkg.check_relationships',1);
--
p_date_effectively_updated := date_effectively_updated (p_element_link_id,
                                                        p_rowid         );
--
p_element_entries_exist := element_entries_exist (      p_element_link_id,
                                                        FALSE           );
--
end check_relationships;
--------------------------------------------------------------------------------
function PAY_BASIS_EXISTS (
--
--******************************************************************************
--* Returns TRUE if a pay basis exists for the element type.                   *
--******************************************************************************
--
-- Parameters are:
--
        p_element_type_id       number
       ,p_business_group_id     number) return boolean
is
  l_pay_basis_exists number;
  l_exists           boolean;
  --
  cursor csr_pay_basis_exists is
    select 1
    from
      pay_input_values_f piv
     ,per_pay_bases      ppb
    where
        piv.element_type_id = p_element_type_id
    and ppb.input_value_id = piv.input_value_id
    and ppb.business_group_id = p_business_group_id
    ;
begin

  open csr_pay_basis_exists;
  fetch csr_pay_basis_exists into l_pay_basis_exists;
  if csr_pay_basis_exists%found then
    l_exists := true;
  else
    l_exists := false;
  end if;
  close csr_pay_basis_exists;

  return l_exists;

end pay_basis_exists;
--------------------------------------------------------------------------------
end PAY_ELEMENT_LINKS_PKG;

/
