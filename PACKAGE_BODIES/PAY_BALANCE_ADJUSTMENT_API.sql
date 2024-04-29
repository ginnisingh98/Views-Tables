--------------------------------------------------------
--  DDL for Package Body PAY_BALANCE_ADJUSTMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BALANCE_ADJUSTMENT_API" as
/* $Header: pybadapi.pkb 120.0 2005/05/29 03:13:50 appldev noship $ */
/*
  NOTES
*/

/*---------------------------------------------------------------------------*/
/*-------------------------- constant definitions ---------------------------*/
/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*/
/*------------------------ balance adjustment types -------------------------*/
/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*/
/*----------------------- balance adjustment globals ------------------------*/
/*---------------------------------------------------------------------------*/
g_package varchar2(33) := '  pay_balance_adjustment_api.';

/*---------------------------------------------------------------------------*/
/*--------------------- local functions and procedures ----------------------*/
/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*/
/*------------------ global functions and procedures ------------------------*/
/*---------------------------------------------------------------------------*/

------------------------------ create_adjustment ------------------------------
/*
  NAME
    create_adjustment
  DESCRIPTION
    Performs a single balance adjustment.
  NOTES
    <none>
*/

procedure create_adjustment
(
   p_validate                   in     boolean  default false,
   p_effective_date             in     date,
   p_assignment_id              in     number,
   p_consolidation_set_id       in     number,
   p_element_link_id            in     number,
   p_input_value_id1            in     number   default null,
   p_input_value_id2            in     number   default null,
   p_input_value_id3            in     number   default null,
   p_input_value_id4            in     number   default null,
   p_input_value_id5            in     number   default null,
   p_input_value_id6            in     number   default null,
   p_input_value_id7            in     number   default null,
   p_input_value_id8            in     number   default null,
   p_input_value_id9            in     number   default null,
   p_input_value_id10           in     number   default null,
   p_input_value_id11           in     number   default null,
   p_input_value_id12           in     number   default null,
   p_input_value_id13           in     number   default null,
   p_input_value_id14           in     number   default null,
   p_input_value_id15           in     number   default null,
   p_entry_value1               in     varchar2 default null,
   p_entry_value2               in     varchar2 default null,
   p_entry_value3               in     varchar2 default null,
   p_entry_value4               in     varchar2 default null,
   p_entry_value5               in     varchar2 default null,
   p_entry_value6               in     varchar2 default null,
   p_entry_value7               in     varchar2 default null,
   p_entry_value8               in     varchar2 default null,
   p_entry_value9               in     varchar2 default null,
   p_entry_value10              in     varchar2 default null,
   p_entry_value11              in     varchar2 default null,
   p_entry_value12              in     varchar2 default null,
   p_entry_value13              in     varchar2 default null,
   p_entry_value14              in     varchar2 default null,
   p_entry_value15              in     varchar2 default null,
   p_prepay_flag                in     varchar2 default null,

   -- Costing information.
   p_balance_adj_cost_flag      in     varchar2 default null,
   p_cost_allocation_keyflex_id in     number   default null,
   p_attribute_category         in     varchar2 default null,
   p_attribute1                 in     varchar2 default null,
   p_attribute2                 in     varchar2 default null,
   p_attribute3                 in     varchar2 default null,
   p_attribute4                 in     varchar2 default null,
   p_attribute5                 in     varchar2 default null,
   p_attribute6                 in     varchar2 default null,
   p_attribute7                 in     varchar2 default null,
   p_attribute8                 in     varchar2 default null,
   p_attribute9                 in     varchar2 default null,
   p_attribute10                in     varchar2 default null,
   p_attribute11                in     varchar2 default null,
   p_attribute12                in     varchar2 default null,
   p_attribute13                in     varchar2 default null,
   p_attribute14                in     varchar2 default null,
   p_attribute15                in     varchar2 default null,
   p_attribute16                in     varchar2 default null,
   p_attribute17                in     varchar2 default null,
   p_attribute18                in     varchar2 default null,
   p_attribute19                in     varchar2 default null,
   p_attribute20                in     varchar2 default null,

   p_run_type_id                in     number   default null,
   p_original_entry_id          in     number   default null,

   -- Element entry information.
   p_element_entry_id              out nocopy number,
   p_effective_start_date          out nocopy date,
   p_effective_end_date            out nocopy date,
   p_object_version_number         out nocopy number,
   p_create_warning                out nocopy boolean
) is
   l_payroll_id             number;
   l_time_period_id         number;
   l_payroll_action_id      number;
   l_assignment_action_id   number;
   l_business_group_id      number;
   l_element_entry_id       number;
   l_effective_start_date   date;
   l_effective_end_date     date;
   l_object_version_number  number;
   l_create_warning         boolean;
   l_proc                   varchar2(72) := g_package ||'create_adjustment';
begin
   hr_utility.set_location('Entering:'|| l_proc, 5);

   savepoint create_adjustment;

   -- Obtain information based on the assignment.
   -- Also get the new payroll_action_id and
   -- time period information.
   hr_utility.set_location(l_proc, 20);
   select asg.business_group_id,
          asg.payroll_id,
          ptp.time_period_id,
          pay_payroll_actions_s.nextval
   into   l_business_group_id,
          l_payroll_id,
          l_time_period_id,
          l_payroll_action_id
   from   per_assignments_f asg,
          per_time_periods  ptp
   where  asg.assignment_id = p_assignment_id
   and    p_effective_date between
          asg.effective_start_date and asg.effective_end_date
   and    ptp.payroll_id    = asg.payroll_id
   and    p_effective_date between
          ptp.start_date and ptp.end_date;

   -- The balance adjustment element entry.
   py_element_entry_api.create_element_entry (
      p_effective_date             => p_effective_date,
      p_business_group_id          => l_business_group_id,
      p_original_entry_id          => p_original_entry_id,
      p_assignment_id              => p_assignment_id,
      p_element_link_id            => p_element_link_id,
      p_entry_type                 => 'B',   -- Balance Adjustment entry.
      p_creator_type               => 'B',
      p_input_value_id1            => p_input_value_id1,
      p_input_value_id2            => p_input_value_id2,
      p_input_value_id3            => p_input_value_id3,
      p_input_value_id4            => p_input_value_id4,
      p_input_value_id5            => p_input_value_id5,
      p_input_value_id6            => p_input_value_id6,
      p_input_value_id7            => p_input_value_id7,
      p_input_value_id8            => p_input_value_id8,
      p_input_value_id9            => p_input_value_id9,
      p_input_value_id10           => p_input_value_id10,
      p_input_value_id11           => p_input_value_id11,
      p_input_value_id12           => p_input_value_id12,
      p_input_value_id13           => p_input_value_id13,
      p_input_value_id14           => p_input_value_id14,
      p_input_value_id15           => p_input_value_id15,
      p_entry_value1               => p_entry_value1,
      p_entry_value2               => p_entry_value2,
      p_entry_value3               => p_entry_value3,
      p_entry_value4               => p_entry_value4,
      p_entry_value5               => p_entry_value5,
      p_entry_value6               => p_entry_value6,
      p_entry_value7               => p_entry_value7,
      p_entry_value8               => p_entry_value8,
      p_entry_value9               => p_entry_value9,
      p_entry_value10              => p_entry_value10,
      p_entry_value11              => p_entry_value11,
      p_entry_value12              => p_entry_value12,
      p_entry_value13              => p_entry_value13,
      p_entry_value14              => p_entry_value14,
      p_entry_value15              => p_entry_value15,

      -- Costing information.
      p_cost_allocation_keyflex_id => p_cost_allocation_keyflex_id,
      p_attribute_category         => p_attribute_category,
      p_attribute1                 => p_attribute1,
      p_attribute2                 => p_attribute2,
      p_attribute3                 => p_attribute3,
      p_attribute4                 => p_attribute4,
      p_attribute5                 => p_attribute5,
      p_attribute6                 => p_attribute6,
      p_attribute7                 => p_attribute7,
      p_attribute8                 => p_attribute8,
      p_attribute9                 => p_attribute9,
      p_attribute10                => p_attribute10,
      p_attribute11                => p_attribute11,
      p_attribute12                => p_attribute12,
      p_attribute13                => p_attribute13,
      p_attribute14                => p_attribute14,
      p_attribute15                => p_attribute15,
      p_attribute16                => p_attribute16,
      p_attribute17                => p_attribute17,
      p_attribute18                => p_attribute18,
      p_attribute19                => p_attribute19,
      p_attribute20                => p_attribute20,
      p_effective_start_date       => l_effective_start_date,
      p_effective_end_date         => l_effective_end_date,
      p_element_entry_id           => l_element_entry_id,
      p_object_version_number      => l_object_version_number,
      p_create_warning             => l_create_warning
   );

   -- Deal with the creation of Payroll and Assignment
   -- Action for the adjustment.  We call the existing
   -- routine to ensure that we get support for altering
   -- latest balances and creation of Action Contexts.
   hrassact.bal_adjust (consetid    => p_consolidation_set_id,
                        eentryid    => l_element_entry_id,
                        effdate     => p_effective_date,
                        prepay_flag => p_prepay_flag,
			run_type_id => p_run_type_id);

   -- Perform an update to the entry.
   -- Entry API doesn't support the bal_adjust_cost_flag.
   -- and ensure that the creator_type is correct.
   hr_utility.set_location(l_proc, 30);
   update pay_element_entries_f pee
   set    pee.creator_type          = 'B',
          pee.balance_adj_cost_flag = p_balance_adj_cost_flag
   where  pee.element_entry_id      = l_element_entry_id
   and    p_effective_date between
          pee.effective_start_date and pee.effective_end_date;

   --
   -- Set remaining output arguments
   --
   p_element_entry_id      := l_element_entry_id;
   p_effective_start_date  := l_effective_start_date;
   p_effective_end_date    := l_effective_end_date;
   p_object_version_number := l_object_version_number;
   p_create_warning        := l_create_warning;

   if(p_validate) then
      raise hr_api.validate_enabled;
   end if;

   hr_utility.set_location(' Leaving:'||l_proc, 40);
exception
   when hr_api.validate_enabled then
   --
   -- As the Validate_Enabled exception has been raised
   -- we must rollback to the savepoint
   --
   ROLLBACK TO create_adjustment;
   --
   -- Only set output warning arguments
   -- (Any key or derived arguments must be set to null
   -- when validation only mode is being used.)
   --
   p_element_entry_id      := null;
   p_effective_start_date  := null;
   p_effective_end_date    := null;
   p_object_version_number := null;
   p_create_warning        := l_create_warning;

when others then
   -- Unexpected error detected.
   ROLLBACK TO create_adjustment;
   raise;

end create_adjustment;

------------------------------ delete_adjustment ------------------------------
/*
  NAME
    delete_adjustment
  DESCRIPTION
    Deletes an existing balance adjustment.
  NOTES
    <none>
*/

procedure delete_adjustment
(
   p_validate         in boolean default false,
   p_effective_date   in date,
   p_element_entry_id in number
) is
   l_payroll_action_id number;
   l_assignment_action_id number;
   l_dummy             number;
   l_proc              varchar2(72) := g_package ||'delete_adjustment';
begin
   hr_utility.set_location('Entering:'|| l_proc, 5);

   savepoint delete_adjustment;

   -- We know the element entry, but we need to know the payroll
   -- action that we have to remove.
   hr_utility.set_location(l_proc, 20);
   select act.payroll_action_id
         ,act.assignment_action_id
   into   l_payroll_action_id
         ,l_assignment_action_id
   from   pay_payroll_actions    ppa,
          pay_assignment_actions act,
          pay_element_entries_f  pee
   where  pee.element_entry_id     = p_element_entry_id
   and    pee.entry_type           = 'B'
   and    p_effective_date between
          pee.effective_start_date and pee.effective_end_date
   and    act.assignment_action_id = pee.creator_id
   and    ppa.payroll_action_id    = act.payroll_action_id
   and    ppa.action_type          = 'B'
   ;

   --
   -- Ensure there are no other assignment actions nor run
   -- results in this payroll action.
   --
   hr_utility.set_location(l_proc, 30);
   begin

     select 1 into l_dummy from dual
     where
         not exists
           (select 1 from pay_assignment_actions paa
            where paa.payroll_action_id = l_payroll_action_id
              and paa.assignment_action_id <> l_assignment_action_id)
     and not exists
           (select 1 from pay_run_results prr
            where prr.assignment_action_id = l_assignment_action_id
              and not (nvl(prr.element_entry_id, prr.source_id) = p_element_entry_id
                       and prr.source_type = 'E'));

   exception
     when no_data_found then
       fnd_message.set_name('PAY', 'HR_7296_API_ARG_NOT_SUP');
       fnd_message.set_token('ARG_NAME', 'p_element_entry_id');
       fnd_message.set_token('ARG_VALUE',to_char(p_element_entry_id));
       fnd_message.raise_error;
   end;

   -- Make use of existing routine to remove this
   -- balance adjustment.
   py_rollback_pkg.rollback_payroll_action(l_payroll_action_id);

   if(p_validate) then
      raise hr_api.validate_enabled;
   end if;

   hr_utility.set_location(' Leaving:'||l_proc, 100);
exception
   when hr_api.validate_enabled then
   --
   -- As the Validate_Enabled exception has been raised
   -- we must rollback to the savepoint
   --
   ROLLBACK TO delete_adjustment;

when others then
   -- Unexpected error detected.
   ROLLBACK TO delete_adjustment;
   raise;

end delete_adjustment;

end pay_balance_adjustment_api;

/
