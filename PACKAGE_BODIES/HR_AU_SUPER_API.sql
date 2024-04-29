--------------------------------------------------------
--  DDL for Package Body HR_AU_SUPER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_AU_SUPER_API" as
/* $Header: hrauwrsu.pkb 115.10 2004/06/07 04:21:16 srrajago ship $ */
/*
 +==========================================================================================
 |              Copyright (c) 1999 Oracle Corporation Ltd
 |                           All rights reserved.
 +==========================================================================================
 |         Description : Super API Wrapper for AU
 |
 |   Name           Date         Version Bug     Text
 |   -------------- ----------   ------- -----   ----
 |   sclarke        11-APR-2000  115.0           Created for AU
 |   sclarke        18-APR-2000  115.1   1272400 change type of p_member_number
 |   sclarke        27-APR-2000  115.3   1281637 add p_element_entry_id parameter
 |   sclarke        02-MAY-2000  115.4   1286209 Also changed super_fund_id, procedure now
 |                                               validates the super fund given
 |   apunekar       24-MAY-2001  115.5   1620646 Changed query in get_payment_id
 |                                               function
 |   jkarouza  	    05-MAR-2002  115.6   2246310 Added new parameter p_override_user_ent_chk
 |                                               in calls to py_element_entry_api.
 |   jkarouza  	    22-MAR-2002  115.7   Added set verify off.
 |   Ragovind       20-NOV-2002  115.8   2665475 Modified the cursor csr_get_super_fund for Performance and removed default for gscc compliance.
 |   Ragovind       04-DEC-2002  115.9   2665475 Modified the cursor csr_get_super_fund for performance improvement and to avoid FTS and added NOCOPY
 |   srrajago       07-JUN-2004  115.10  3648796 Performance Fix to remove FTS. Assigned the correct element name to the variable
 |                                               g_super_element (as in seed). In the cursor csr_super_element,removed the UPPER function.
 |                                               Removed GSCC warnings(File.Sql.35).
 |
 |NOTES
 +==========================================================================================
*/
-----------------------------------
-- PRIVATE constants and variables
-----------------------------------
type number_table                 is table of number not null index by binary_integer;
type varchar2_table               is table of varchar2(60) index by binary_integer;

g_package                           constant varchar2(33)   := 'hr_au_super_api.';
g_super_element                     constant varchar2(60)   := 'Superannuation Contribution'; -- Bug: 3648796
g_super_input1                      constant varchar2(60)   := 'PAY VALUE';
g_super_input2                      constant varchar2(60)   := 'MEMBER NUMBER';
g_super_input3                      constant varchar2(60)   := 'SG AMOUNT';
g_super_input4                      constant varchar2(60)   := 'SG PERCENT';
g_super_input5                      constant varchar2(60)   := 'NON SG AMOUNT';
g_super_input6                      constant varchar2(60)   := 'NON SG PERCENT';
g_legislation_code                  constant varchar2(2)    := 'AU';
--
function get_payment_method
(p_assignment_id                            number
,p_super_fund_name                          varchar2
,p_effective_date                           date
) return number is
  --
  cursor csr_get_super_fund
  (p_assignment_id                          number
  ,p_super_fund_name                        varchar2
  ,p_effective_date                         date
  ) is
  select pppmf.personal_payment_method_id
  from   pay_personal_payment_methods_f     pppmf
  ,      hr_organization_information        hou
  ,      per_all_assignments_f              paaf
  where  paaf.assignment_id                 = p_assignment_id
  and    pppmf.payee_type                   = 'O'
  and    pppmf.payee_id                     = hou.organization_id
  and    pppmf.assignment_id                = paaf.assignment_id
  and    upper(p_super_fund_name)           = upper(hou.org_information2)
  and    p_effective_date                   between pppmf.effective_start_date and pppmf.effective_end_date
  and    p_effective_date                   between paaf.effective_start_date and paaf.effective_end_date;
  --
  l_personal_payment_method_id              number;
  l_procedure                               constant varchar2(60)   := 'get_payment_method';
  --
begin
  hr_utility.set_location(g_package||l_procedure, 1);
  open csr_get_super_fund
  (p_assignment_id
  ,p_super_fund_name
  ,p_effective_date
  );
  fetch csr_get_super_fund
  into l_personal_payment_method_id;
  if csr_get_super_fund%notfound
  then
    close csr_get_super_fund;
    hr_utility.trace('Invalid super fund: '||p_super_fund_name||' for assignment_id = '||to_char(p_assignment_id));
    hr_utility.set_message(801,'HR_AU_SUPER_FUND_NOT_VALID');
    hr_utility.raise_error;
  end if;
  close csr_get_super_fund;
  return l_personal_payment_method_id;
  --
  hr_utility.set_location(g_package||l_procedure, 99);
end get_payment_method;
--
---------------------------------------------------------------------------------------------
--              PRIVATE FUNCTION valid_business_group
---------------------------------------------------------------------------------------------
--
function valid_business_group
(p_business_group_id    number
) return boolean is
  --
  l_procedure           constant varchar2(60)   := 'valid_business_group';
  l_legislation_code    varchar2(30);
  --
  cursor csr_per_business_groups
  is
  select legislation_code
  from   per_business_groups
  where  business_group_id      = p_business_group_id;
  --
begin
  hr_utility.set_location(g_package||l_procedure, 1);
  open csr_per_business_groups;
  fetch csr_per_business_groups
  into l_legislation_code;
  if csr_per_business_groups%notfound
  then
    close csr_per_business_groups;
    hr_utility.set_location(g_package||l_procedure, 2);
    hr_utility.trace('p_business_group_id: '||to_char(p_business_group_id));
    return false;
  end if;
  close csr_per_business_groups;
  --
  hr_utility.set_location(g_package||l_procedure, 10);
  if l_legislation_code = g_legislation_code
  then
    return true;
  else
    return false;
  end if;
  --
end valid_business_group;
--
---------------------------------------------------------------------------------------------
--              PRIVATE FUNCTION validate_percent_variables
---------------------------------------------------------------------------------------------
--
function validate_percent_variables
(p_sg_percent           number
,p_non_sg_percent       number
) return boolean is
  --
  l_procedure           constant varchar2(60)   := 'validate_percent_variables';
  --
begin
  hr_utility.set_location(g_package||l_procedure,1);
  --
  -- Check perentage amounts are between 0 and 100
  --
  if (p_sg_percent is not null)
  then
    if (p_sg_percent not between 0 and 100)
    then
      hr_utility.trace('p_sg_percent: '||to_char(p_sg_percent));
      return false;
    end if;
  end if;
  --
  if (p_non_sg_percent is not null)
  then
    if (p_non_sg_percent not between 0 and 100)
    then
      hr_utility.trace('p_non_sg_percent: '||to_char(p_non_sg_percent));
      return false;
    end if;
  end if;
  hr_utility.set_location(g_package||l_procedure,10);
  return true;
end validate_percent_variables;
--
---------------------------------------------------------------------------------------------
--          PRIVATE PROCEDURE get_super_input_ids
---------------------------------------------------------------------------------------------
--
procedure get_super_input_ids
(p_effective_date           in      date
,p_element_type_id          in out NOCOPY pay_element_types_f.element_type_id%type
,p_inp_value_id_table       in out NOCOPY number_table
) is
  --
  l_procedure                       constant varchar2(60)   := 'get_super_input_ids';
  --
  cursor csr_super_input_values
  (p_element_type_id  pay_input_values_f.element_type_id%type
  ,p_effective_date   date
  ) is
  select piv.input_value_id
  ,      piv.name
  from   pay_input_values_f         piv
  where  piv.element_type_id        = p_element_type_id
  and    p_effective_date           between piv.effective_start_date and piv.effective_end_date;
  --
  cursor csr_super_element
  (p_effective_date         date
  ) is
  select pet.element_type_id
  from   pay_element_types_f  pet
  where  pet.element_name    = g_super_element   -- Bug: 3648796
  and    p_effective_date    between pet.effective_start_date and pet.effective_end_date
  and    legislation_code    = g_legislation_code;
  --
begin
  --
  -- get the element type id for the super element
  --
  hr_utility.set_location(g_package||l_procedure, 1);
  --
  open csr_super_element(p_effective_date);
  fetch csr_super_element
  into p_element_type_id;
  if (csr_super_element%notfound)
  then
    close csr_super_element;
    hr_utility.trace('p_effective_date: '||to_char(p_effective_date,'MM/DD/YYYY'));
    hr_utility.set_message(801,'HR_AU_NZ_ELE_TYP_NOT_FND');
    hr_utility.raise_error;
  end if;
  close csr_super_element;
  --
  -- get the input value id for each tax input
  --
  for rec_super_element in csr_super_input_values(p_element_type_id, p_effective_date)
  loop
    if upper(rec_super_element.name) = g_super_input1
    then
      p_inp_value_id_table(1) := rec_super_element.input_value_id;
      --
    elsif upper(rec_super_element.name) = g_super_input2
    then
      p_inp_value_id_table(2) := rec_super_element.input_value_id;
      --
    elsif upper(rec_super_element.name) = g_super_input3
    then
      p_inp_value_id_table(3) := rec_super_element.input_value_id;
      --
    elsif upper(rec_super_element.name) = g_super_input4
    then
      p_inp_value_id_table(4) := rec_super_element.input_value_id;
      --
    elsif upper(rec_super_element.name) = g_super_input5
    then
      p_inp_value_id_table(5) := rec_super_element.input_value_id;
      --
    elsif upper(rec_super_element.name) = g_super_input6
    then
      p_inp_value_id_table(6) := rec_super_element.input_value_id;
      --
    else
      hr_utility.trace('p_element_type_id: '||to_char(p_element_type_id));
      hr_utility.trace('Input name: '||rec_super_element.name);
      hr_utility.trace('p_effective_date: '||to_char(p_effective_date,'MM/DD/YYYY'));
      hr_utility.set_message(801,'HR_NZ_INPUT_VALUE_NOT_FOUND');
      hr_utility.raise_error;
    end if;
  end loop;
  --
  hr_utility.set_location(g_package||l_procedure, 10);
  --
end get_super_input_ids;
--
---------------------------------------------------------------------------------------------
--      PUBLIC PROCEDURE update_super_contribution
---------------------------------------------------------------------------------------------
--      27-apr-2000         added parameter for p_element_entry_id
--                          because this Element accepts multiple entries
--
procedure update_super_contribution
(p_validate                         in      boolean
,p_assignment_id                    in      number
,p_session_date                     in      date
,p_mode                             in      varchar2
,p_business_group_id                in      number
,p_element_entry_id                 in      number
,p_super_fund_name                  in      varchar2
,p_attribute_category               in      varchar2
,p_attribute1                       in      varchar2
,p_attribute2                       in      varchar2
,p_attribute3                       in      varchar2
,p_attribute4                       in      varchar2
,p_attribute5                       in      varchar2
,p_attribute6                       in      varchar2
,p_attribute7                       in      varchar2
,p_attribute8                       in      varchar2
,p_attribute9                       in      varchar2
,p_attribute10                      in      varchar2
,p_attribute11                      in      varchar2
,p_attribute12                      in      varchar2
,p_attribute13                      in      varchar2
,p_attribute14                      in      varchar2
,p_attribute15                      in      varchar2
,p_attribute16                      in      varchar2
,p_attribute17                      in      varchar2
,p_attribute18                      in      varchar2
,p_attribute19                      in      varchar2
,p_attribute20                      in      varchar2
,p_pay_value                        in      number
,p_member_number                    in      varchar2
,p_sg_amount                        in      number
,p_sg_percent                       in      number
,p_non_sg_amount                    in      number
,p_non_sg_percent                   in      number
,p_effective_start_date                out NOCOPY date
,p_effective_end_date                  out NOCOPY date
,p_update_warning                      out NOCOPY boolean
) is
  l_inp_value_id_table              number_table;
  l_scr_value_table                 varchar2_table;

  l_dummy                           number  := null;
  l_element_type_id                 number  :=0;
  l_element_link_id                 number  :=0;
  l_element_entry_id                number  :=0;
  l_object_version_number           number;
  l_effective_start_date            date;
  l_effective_end_date              date;
  l_super_fund_id                   number;
  l_session_date                    date;
  l_procedure                       varchar2(33); -- Bug: 3648796
  --
  cursor csr_ele_entry
  (p_element_link                   number
  ,p_inp_val                        number
  ,p_element_entry_id               number
  )is
  select pee.element_entry_id
  ,      object_version_number
  from   pay_element_entries_f      pee
  ,      pay_element_entry_values_f pev
  where  pee.assignment_id          = p_assignment_id
  and    l_session_date             between pee.effective_start_date and pee.effective_end_date
  and    pee.element_link_id        = p_element_link
  and    pev.element_entry_id       = pee.element_entry_id
  and    l_session_date             between pev.effective_start_date and pev.effective_end_date
  and    pee.element_entry_id       = p_element_entry_id
  and    pev.input_value_id         = p_inp_val;
  --
begin
  l_procedure    := 'update_super_contribution'; -- Bug: 3648796

  hr_utility.set_location(g_package||l_procedure, 1);

  l_session_date := trunc(p_session_date);
  --
  -- Ensure business group supplied is Australian
  --
  if not valid_business_group(p_business_group_id)
  then
    hr_utility.set_location(g_package||l_procedure, 2);
    hr_utility.set_message(801,'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  --
  -- Check perentage amounts are between 0 and 100
  --
  if not validate_percent_variables(p_sg_percent, p_non_sg_percent)
  then
    hr_utility.set_message(801,'HR_AU_PERCENT_NOT_VALID');
    hr_utility.raise_error;
  end if;
  --
  -- Get Element type id and input value ids
  --
  get_super_input_ids(l_session_date, l_element_type_id, l_inp_value_id_table);
  --
  -- Get the element link id for the Superannuation Contribution element
  --
  l_element_link_id     := hr_entry_api.get_link
                           (p_assignment_id     => p_assignment_id
                           ,p_element_type_id   => l_element_type_id
                           ,p_session_date      => l_session_date
                           );
  if (l_element_link_id is null or l_element_link_id = 0)
  then
    hr_utility.set_message(801,'HR_AU_NZ_ELE_LNK_NOT_FND');
    hr_utility.raise_error;
  end if;

  -----------------------------------------------------------------------------
  -- verify the element entry is the super entry that is to be updated
  ------------------------------------------------------------------------------
  hr_utility.set_location(g_package||l_procedure ,7);
  --
  open csr_ele_entry(l_element_link_id, l_inp_value_id_table(1), p_element_entry_id);
  fetch csr_ele_entry into l_element_entry_id, l_object_version_number;
  if (csr_ele_entry%notfound)
  then
    close csr_ele_entry;
    hr_utility.set_message(801,'HR_AU_NZ_ELE_ENT_NOT_FND');
    hr_utility.raise_error;
  end if;
  close csr_ele_entry;
  --
  -- Get the personal_payment_method_id for the super fund
  --
  l_super_fund_id := get_payment_method
                    (p_assignment_id
                    ,p_super_fund_name
                    ,l_session_date
                    );
  --
  py_element_entry_api.update_element_entry
  (p_validate                     => p_validate
  ,p_datetrack_update_mode        => p_mode
  ,p_effective_date               => l_session_date
  ,p_business_group_id            => p_business_group_id
  ,p_element_entry_id             => l_element_entry_id
  ,p_object_version_number        => l_object_version_number
  ,p_personal_payment_method_id   => l_super_fund_id
  ,p_attribute_category           => p_attribute_category
  ,p_attribute1                   => p_attribute1
  ,p_attribute2                   => p_attribute2
  ,p_attribute3                   => p_attribute3
  ,p_attribute4                   => p_attribute4
  ,p_attribute5                   => p_attribute5
  ,p_attribute6                   => p_attribute6
  ,p_attribute7                   => p_attribute7
  ,p_attribute8                   => p_attribute8
  ,p_attribute9                   => p_attribute9
  ,p_attribute10                  => p_attribute10
  ,p_attribute11                  => p_attribute11
  ,p_attribute12                  => p_attribute12
  ,p_attribute13                  => p_attribute13
  ,p_attribute14                  => p_attribute14
  ,p_attribute15                  => p_attribute15
  ,p_attribute16                  => p_attribute16
  ,p_attribute17                  => p_attribute17
  ,p_attribute18                  => p_attribute18
  ,p_attribute19                  => p_attribute19
  ,p_attribute20                  => p_attribute20
  ,p_input_value_id1              => l_inp_value_id_table(1)
  ,p_input_value_id2              => l_inp_value_id_table(2)
  ,p_input_value_id3              => l_inp_value_id_table(3)
  ,p_input_value_id4              => l_inp_value_id_table(4)
  ,p_input_value_id5              => l_inp_value_id_table(5)
  ,p_input_value_id6              => l_inp_value_id_table(6)
  ,p_entry_value1                 => p_pay_value
  ,p_entry_value2                 => p_member_number
  ,p_entry_value3                 => p_sg_amount
  ,p_entry_value4                 => p_sg_percent
  ,p_entry_value5                 => p_non_sg_amount
  ,p_entry_value6                 => p_non_sg_percent
  ,p_effective_start_date         => l_effective_start_date
  ,p_effective_end_date           => l_effective_end_date
  ,p_override_user_ent_chk	  => 'Y'
  ,p_update_warning               => p_update_warning
  );
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  hr_utility.set_location(g_package||l_procedure, 30);
end update_super_contribution;
--
---------------------------------------------------------------------------------------------
--      PUBLIC PROCEDURE create_super_contribution
---------------------------------------------------------------------------------------------
--
procedure create_super_contribution
(p_validate                      in     boolean
,p_effective_date                in     date
,p_business_group_id             in     number
,p_original_entry_id             in     number
,p_assignment_id                 in     number
,p_entry_type                    in     varchar2
,p_cost_allocation_keyflex_id    in     number
,p_updating_action_id            in     number
,p_comment_id                    in     number
,p_reason                        in     varchar2
,p_target_entry_id               in     number
,p_subpriority                   in     number
,p_date_earned                   in     date
,p_super_fund_name               in     varchar2
,p_attribute_category            in     varchar2
,p_attribute1                    in     varchar2
,p_attribute2                    in     varchar2
,p_attribute3                    in     varchar2
,p_attribute4                    in     varchar2
,p_attribute5                    in     varchar2
,p_attribute6                    in     varchar2
,p_attribute7                    in     varchar2
,p_attribute8                    in     varchar2
,p_attribute9                    in     varchar2
,p_attribute10                   in     varchar2
,p_attribute11                   in     varchar2
,p_attribute12                   in     varchar2
,p_attribute13                   in     varchar2
,p_attribute14                   in     varchar2
,p_attribute15                   in     varchar2
,p_attribute16                   in     varchar2
,p_attribute17                   in     varchar2
,p_attribute18                   in     varchar2
,p_attribute19                   in     varchar2
,p_attribute20                   in     varchar2
,p_pay_value                     in     number
,p_member_number                 in     varchar2
,p_sg_amount                     in     number
,p_sg_percent                    in     number
,p_non_sg_amount                 in     number
,p_non_sg_percent                in     number
,p_effective_start_date             out NOCOPY date
,p_effective_end_date               out NOCOPY date
,p_element_entry_id                 out NOCOPY number
,p_object_version_number            out NOCOPY number
,p_create_warning                   out NOCOPY boolean
) is
  --
  l_procedure                   varchar2(33);
  l_inp_value_id_table          number_table;
  l_effective_start_date        date;
  l_effective_end_date          date;
  l_element_entry_id            number;
  l_object_version_number       number;
  l_create_warning              boolean;
  l_element_type_id             number;
  l_element_link_id             number;
  l_super_fund_id               number;
  --
begin
  l_procedure  := 'create_super_contribution';  -- Bug: 3648796

  hr_utility.set_location(g_package||l_procedure, 1);

  --
  -- Ensure business group supplied is Australian
  --
  if not valid_business_group(p_business_group_id)
  then
    hr_utility.set_location(g_package||l_procedure, 2);
    hr_utility.set_message(801,'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  --
  -- Check perentage amounts are between 0 and 100
  --
  if not validate_percent_variables(p_sg_percent, p_non_sg_percent)
  then
    hr_utility.set_message(801,'HR_AU_PERCENT_NOT_VALID');
    hr_utility.raise_error;
  end if;
  --
  -- Get Element type id and input value ids
  --
  get_super_input_ids(p_effective_date, l_element_type_id, l_inp_value_id_table);
  --
  -- Get the element link id for the Superannuation Contribution element
  --
  l_element_link_id     := hr_entry_api.get_link
                           (p_assignment_id     => p_assignment_id
                           ,p_element_type_id   => l_element_type_id
                           ,p_session_date      => p_effective_date
                           );
  if (l_element_link_id is null or l_element_link_id = 0)
  then
    hr_utility.set_message(801,'HR_AU_NZ_ELE_LNK_NOT_FND');
    hr_utility.raise_error;
  end if;
  --
  --
  -- Get the personal_payment_method_id for the super fund
  --
  l_super_fund_id := get_payment_method
                    (p_assignment_id
                    ,p_super_fund_name
                    ,p_effective_date
                    );
  --
  py_element_entry_api.create_element_entry
  (p_validate                      => p_validate
  ,p_effective_date                => p_effective_date
  ,p_business_group_id             => p_business_group_id
  ,p_original_entry_id             => p_original_entry_id
  ,p_assignment_id                 => p_assignment_id
  ,p_element_link_id               => l_element_link_id
  ,p_entry_type                    => p_entry_type
  ,p_cost_allocation_keyflex_id    => p_cost_allocation_keyflex_id
  ,p_updating_action_id            => p_updating_action_id
  ,p_comment_id                    => p_comment_id
  ,p_reason                        => p_reason
  ,p_target_entry_id               => p_target_entry_id
  ,p_subpriority                   => p_subpriority
  ,p_date_earned                   => p_date_earned
  ,p_personal_payment_method_id    => l_super_fund_id
  ,p_attribute_category            => p_attribute_category
  ,p_attribute1                    => p_attribute1
  ,p_attribute2                    => p_attribute2
  ,p_attribute3                    => p_attribute3
  ,p_attribute4                    => p_attribute4
  ,p_attribute5                    => p_attribute5
  ,p_attribute6                    => p_attribute6
  ,p_attribute7                    => p_attribute7
  ,p_attribute8                    => p_attribute8
  ,p_attribute9                    => p_attribute9
  ,p_attribute10                   => p_attribute10
  ,p_attribute11                   => p_attribute11
  ,p_attribute12                   => p_attribute12
  ,p_attribute13                   => p_attribute13
  ,p_attribute14                   => p_attribute14
  ,p_attribute15                   => p_attribute15
  ,p_attribute16                   => p_attribute16
  ,p_attribute17                   => p_attribute17
  ,p_attribute18                   => p_attribute18
  ,p_attribute19                   => p_attribute19
  ,p_attribute20                   => p_attribute20
  ,p_input_value_id1               => l_inp_value_id_table(1)
  ,p_input_value_id2               => l_inp_value_id_table(2)
  ,p_input_value_id3               => l_inp_value_id_table(3)
  ,p_input_value_id4               => l_inp_value_id_table(4)
  ,p_input_value_id5               => l_inp_value_id_table(5)
  ,p_input_value_id6               => l_inp_value_id_table(6)
  ,p_entry_value1                  => p_pay_value
  ,p_entry_value2                  => p_member_number
  ,p_entry_value3                  => p_sg_amount
  ,p_entry_value4                  => p_sg_percent
  ,p_entry_value5                  => p_non_sg_amount
  ,p_entry_value6                  => p_non_sg_percent
  ,p_effective_start_date          => p_effective_start_date
  ,p_effective_end_date            => p_effective_end_date
  ,p_override_user_ent_chk	   => 'Y'
  ,p_element_entry_id              => l_element_entry_id
  ,p_object_version_number         => l_object_version_number
  ,p_create_warning                => l_create_warning
  );
  --
  hr_utility.set_location(g_package||l_procedure, 30);
end create_super_contribution;

end hr_au_super_api ;

/
