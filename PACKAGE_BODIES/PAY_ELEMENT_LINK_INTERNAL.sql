--------------------------------------------------------
--  DDL for Package Body PAY_ELEMENT_LINK_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ELEMENT_LINK_INTERNAL" as
/* $Header: pypelbsi.pkb 120.0 2006/10/05 13:28:34 thabara noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'pay_element_link_internal.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------<create_element_link>--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_element_link
  (p_effective_date                  in     date
  ,p_element_type_id                 in     number
  ,p_business_group_id               in     number
  ,p_costable_type                   in     varchar2
  ,p_payroll_id                      in     number     default null
  ,p_job_id                          in     number     default null
  ,p_position_id                     in     number     default null
  ,p_people_group_id                 in     number     default null
  ,p_cost_allocation_keyflex_id      in out nocopy number
  ,p_organization_id                 in     number     default null
  ,p_location_id                     in     number     default null
  ,p_grade_id                        in     number     default null
  ,p_balancing_keyflex_id            in out nocopy number
  ,p_element_set_id                  in     number     default null
  ,p_pay_basis_id                    in     number     default null
  ,p_link_to_all_payrolls_flag       in     varchar2   default 'N'
  ,p_standard_link_flag              in out nocopy varchar2
  ,p_transfer_to_gl_flag             in     varchar2   default 'N'
  ,p_comments                        in     varchar2   default null
  ,p_employment_category             in     varchar2   default null
  ,p_qualifying_age                  in     number     default null
  ,p_qualifying_length_of_service    in     number     default null
  ,p_qualifying_units                in     varchar2   default null
  ,p_attribute_category              in     varchar2   default null
  ,p_attribute1                      in     varchar2   default null
  ,p_attribute2                      in     varchar2   default null
  ,p_attribute3                      in     varchar2   default null
  ,p_attribute4                      in     varchar2   default null
  ,p_attribute5                      in     varchar2   default null
  ,p_attribute6                      in     varchar2   default null
  ,p_attribute7                      in     varchar2   default null
  ,p_attribute8                      in     varchar2   default null
  ,p_attribute9                      in     varchar2   default null
  ,p_attribute10                     in     varchar2   default null
  ,p_attribute11                     in     varchar2   default null
  ,p_attribute12                     in     varchar2   default null
  ,p_attribute13                     in     varchar2   default null
  ,p_attribute14                     in     varchar2   default null
  ,p_attribute15                     in     varchar2   default null
  ,p_attribute16                     in     varchar2   default null
  ,p_attribute17                     in     varchar2   default null
  ,p_attribute18                     in     varchar2   default null
  ,p_attribute19                     in     varchar2   default null
  ,p_attribute20                     in     varchar2   default null
  ,p_cost_segment1                   in     varchar2   default null
  ,p_cost_segment2                   in     varchar2   default null
  ,p_cost_segment3                   in     varchar2   default null
  ,p_cost_segment4                   in     varchar2   default null
  ,p_cost_segment5                   in     varchar2   default null
  ,p_cost_segment6                   in     varchar2   default null
  ,p_cost_segment7                   in     varchar2   default null
  ,p_cost_segment8                   in     varchar2   default null
  ,p_cost_segment9                   in     varchar2   default null
  ,p_cost_segment10                  in     varchar2   default null
  ,p_cost_segment11                  in     varchar2   default null
  ,p_cost_segment12                  in     varchar2   default null
  ,p_cost_segment13                  in     varchar2   default null
  ,p_cost_segment14                  in     varchar2   default null
  ,p_cost_segment15                  in     varchar2   default null
  ,p_cost_segment16                  in     varchar2   default null
  ,p_cost_segment17                  in     varchar2   default null
  ,p_cost_segment18                  in     varchar2   default null
  ,p_cost_segment19                  in     varchar2   default null
  ,p_cost_segment20                  in     varchar2   default null
  ,p_cost_segment21                  in     varchar2   default null
  ,p_cost_segment22                  in     varchar2   default null
  ,p_cost_segment23                  in     varchar2   default null
  ,p_cost_segment24                  in     varchar2   default null
  ,p_cost_segment25                  in     varchar2   default null
  ,p_cost_segment26                  in     varchar2   default null
  ,p_cost_segment27                  in     varchar2   default null
  ,p_cost_segment28                  in     varchar2   default null
  ,p_cost_segment29                  in     varchar2   default null
  ,p_cost_segment30                  in     varchar2   default null
  ,p_balance_segment1                in     varchar2   default null
  ,p_balance_segment2                in     varchar2   default null
  ,p_balance_segment3                in     varchar2   default null
  ,p_balance_segment4                in     varchar2   default null
  ,p_balance_segment5                in     varchar2   default null
  ,p_balance_segment6                in     varchar2   default null
  ,p_balance_segment7                in     varchar2   default null
  ,p_balance_segment8                in     varchar2   default null
  ,p_balance_segment9                in     varchar2   default null
  ,p_balance_segment10               in     varchar2   default null
  ,p_balance_segment11               in     varchar2   default null
  ,p_balance_segment12               in     varchar2   default null
  ,p_balance_segment13               in     varchar2   default null
  ,p_balance_segment14               in     varchar2   default null
  ,p_balance_segment15               in     varchar2   default null
  ,p_balance_segment16               in     varchar2   default null
  ,p_balance_segment17               in     varchar2   default null
  ,p_balance_segment18               in     varchar2   default null
  ,p_balance_segment19               in     varchar2   default null
  ,p_balance_segment20               in     varchar2   default null
  ,p_balance_segment21               in     varchar2   default null
  ,p_balance_segment22               in     varchar2   default null
  ,p_balance_segment23               in     varchar2   default null
  ,p_balance_segment24               in     varchar2   default null
  ,p_balance_segment25               in     varchar2   default null
  ,p_balance_segment26               in     varchar2   default null
  ,p_balance_segment27               in     varchar2   default null
  ,p_balance_segment28               in     varchar2   default null
  ,p_balance_segment29               in     varchar2   default null
  ,p_balance_segment30               in     varchar2   default null
  ,p_cost_concat_segments            in     varchar2
  ,p_balance_concat_segments         in     varchar2
  ,p_element_link_id		     out nocopy    number
  ,p_comment_id			     out nocopy    number
  ,p_object_version_number	     out nocopy    number
  ,p_effective_start_date	     out nocopy    date
  ,p_effective_end_date		     out nocopy    date
) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_element_link';
  l_effective_date      date;

  -- The variables to get the cost/balance id and structure number
  l_flex_num		number;
  l_cost_allocation_id  number := p_cost_allocation_keyflex_id;
  l_bal_allocation_id   number := p_balancing_keyflex_id;

  -- Variable used to collect the concat segments. Not used furthur hence
  -- called temp
  l_temp		varchar2(1000);

  -- Variable to collect the default standard link flag,Qualifying conditions
  -- and multiply value flag from the element type
  l_standard_link_flag  pay_element_links_f.standard_link_flag%type;
  l_qualifying_age      pay_element_links_f.qualifying_age%type;
  l_qualifying_length_of_service
                        pay_element_links_f.qualifying_length_of_service%type;
  l_qualifying_units    pay_element_links_f.qualifying_units%type;
  l_multiply_value_flag pay_element_links_f.multiply_value_flag%type;

  -- Cursor to get the structure number to be passed to get the cost/balance id
  cursor csr_flexnum is
  select cost_allocation_structure
  from per_business_groups
  where business_group_id = p_business_group_id;
  --
  -- Variables to hold the values returned.
  --
  l_element_link_id          number;
  l_comment_id               number;
  l_object_version_number    number;
  l_effective_start_date     date;
  l_effective_end_date       date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

-- If the costable type is Distributed/Costed/Fixed Costed then call hr_kflex_utility for
-- mandatory balancing segments

  if (p_costable_type = 'D' or p_costable_type = 'C'
      or p_costable_type = 'F') then

      if (l_bal_allocation_id is null
         or l_cost_allocation_id is null) then

         -- Call to hr_kflex_utility.ins_or_sel_keyflex_comb
	 open csr_Flexnum;
	 fetch csr_Flexnum into l_flex_num;
	 if csr_Flexnum%notfound then
	   close csr_Flexnum;
	   hr_utility.set_message(801,'HR_7471_FLEX_PEA_INVALID_ID');
	   hr_utility.raise_error;
	 end if;
      end if;

      if l_bal_allocation_id is null then
        hr_kflex_utility.ins_or_sel_keyflex_comb
	(p_appl_short_name     => 'PAY'
	,p_flex_code           => 'COST'
	,p_flex_num            => l_flex_num
	,p_segment1            => p_balance_segment1
	,p_segment2            => p_balance_segment2
	,p_segment3            => p_balance_segment3
	,p_segment4            => p_balance_segment4
	,p_segment5            => p_balance_segment5
	,p_segment6            => p_balance_segment6
	,p_segment7            => p_balance_segment7
	,p_segment8            => p_balance_segment8
	,p_segment9            => p_balance_segment9
	,p_segment10           => p_balance_segment10
	,p_segment11           => p_balance_segment11
	,p_segment12           => p_balance_segment12
	,p_segment13           => p_balance_segment13
	,p_segment14           => p_balance_segment14
	,p_segment15           => p_balance_segment15
	,p_segment16           => p_balance_segment16
	,p_segment17           => p_balance_segment17
	,p_segment18           => p_balance_segment18
	,p_segment19           => p_balance_segment19
	,p_segment20           => p_balance_segment20
	,p_segment21           => p_balance_segment21
	,p_segment22           => p_balance_segment22
	,p_segment23           => p_balance_segment23
	,p_segment24           => p_balance_segment24
	,p_segment25           => p_balance_segment25
	,p_segment26           => p_balance_segment26
	,p_segment27           => p_balance_segment27
	,p_segment28           => p_balance_segment28
	,p_segment29           => p_balance_segment29
	,p_segment30           => p_balance_segment30
	,p_concat_segments_in  => p_balance_concat_segments
	,p_ccid                => l_bal_allocation_id
	,p_concat_segments_out => l_temp
	);
      end if;

     -- Call the hr_kflex_untility for optional costing if that info is supplied
     -- In case if p_cost_allocation_keyflex_id is supplied then there is no need
     -- to get the costing id again.

     if l_cost_allocation_id is null and
       (p_cost_segment1 is not null or p_cost_segment2 is not null or
        p_cost_segment3 is not null or p_cost_segment4 is not null or
        p_cost_segment5 is not null or p_cost_segment6 is not null or
        p_cost_segment7 is not null or p_cost_segment8 is not null or
        p_cost_segment9 is not null or p_cost_segment10 is not null or
        p_cost_segment11 is not null or p_cost_segment12 is not null or
        p_cost_segment13 is not null or p_cost_segment14 is not null or
        p_cost_segment15 is not null or p_cost_segment16 is not null or
        p_cost_segment17 is not null or p_cost_segment18 is not null or
        p_cost_segment19 is not null or p_cost_segment20 is not null or
        p_cost_segment21 is not null or p_cost_segment22 is not null or
        p_cost_segment23 is not null or p_cost_segment24 is not null or
        p_cost_segment25 is not null or p_cost_segment26 is not null or
        p_cost_segment27 is not null or p_cost_segment28 is not null or
        p_cost_segment29 is not null or p_cost_segment30 is not null) then

       hr_kflex_utility.ins_or_sel_keyflex_comb
	(p_appl_short_name     => 'PAY'
	,p_flex_code           => 'COST'
	,p_flex_num            => l_flex_num
	,p_segment1            => p_cost_segment1
	,p_segment2            => p_cost_segment2
	,p_segment3            => p_cost_segment3
	,p_segment4            => p_cost_segment4
	,p_segment5            => p_cost_segment5
	,p_segment6            => p_cost_segment6
	,p_segment7            => p_cost_segment7
	,p_segment8            => p_cost_segment8
	,p_segment9            => p_cost_segment9
	,p_segment10           => p_cost_segment10
	,p_segment11           => p_cost_segment11
	,p_segment12           => p_cost_segment12
	,p_segment13           => p_cost_segment13
	,p_segment14           => p_cost_segment14
	,p_segment15           => p_cost_segment15
	,p_segment16           => p_cost_segment16
	,p_segment17           => p_cost_segment17
	,p_segment18           => p_cost_segment18
	,p_segment19           => p_cost_segment19
	,p_segment20           => p_cost_segment20
	,p_segment21           => p_cost_segment21
	,p_segment22           => p_cost_segment22
	,p_segment23           => p_cost_segment23
	,p_segment24           => p_cost_segment24
	,p_segment25           => p_cost_segment25
	,p_segment26           => p_cost_segment26
	,p_segment27           => p_cost_segment27
	,p_segment28           => p_cost_segment28
	,p_segment29           => p_cost_segment29
	,p_segment30           => p_cost_segment30
	,p_concat_segments_in  => p_cost_concat_segments
	,p_ccid                => l_cost_allocation_id
	,p_concat_segments_out => l_temp
	);
     end if;
  end if;
 --
 begin
   if p_qualifying_length_of_service is not null
      and (p_qualifying_length_of_service < 0
           or to_number(p_qualifying_length_of_service,'9999.99')
                        <> to_number(p_qualifying_length_of_service)) then
        fnd_message.set_name('PAY', 'PAY_33097_QUALI_LOS_CHECK');
        fnd_message.raise_error;
   end if;
 exception
   when others then
   fnd_message.set_name('PAY', 'PAY_33097_QUALI_LOS_CHECK');
   fnd_message.raise_error;
 end;
 --
 -- Assign values of those parameters who need to be defaulted on basis of
 -- element type. These are assigned to variable as these are used as
 -- in/out parameters in chk_defaults procedure.
 --
  l_standard_link_flag := p_standard_link_flag;
  l_qualifying_age     := p_qualifying_age;
  l_qualifying_length_of_service := p_qualifying_length_of_service;
  l_qualifying_units  := p_qualifying_units;
  -- Defaults the values
  pay_pel_bus.chk_defaults
  (p_element_type_id              => p_element_type_id
  ,p_qualifying_age               => l_qualifying_age
  ,p_qualifying_length_of_service => l_qualifying_length_of_service
  ,p_qualifying_units             => l_qualifying_units
  ,p_multiply_value_flag          => l_multiply_value_flag
  ,p_standard_link_flag           => l_standard_link_flag
  ,p_effective_date		  => l_effective_date
  );

  --
  -- Process Logic
  --
  pay_pel_ins.ins(
   p_effective_date                => l_effective_date
  ,p_element_type_id               => p_element_type_id
  ,p_business_group_id             => p_business_group_id
  ,p_costable_type                 => p_costable_type
  ,p_link_to_all_payrolls_flag     => p_link_to_all_payrolls_flag
  ,p_multiply_value_flag           => l_multiply_value_flag
  ,p_standard_link_flag            => l_standard_link_flag
  ,p_transfer_to_gl_flag           => p_transfer_to_gl_flag
  ,p_payroll_id                    => p_payroll_id
  ,p_job_id                        => p_job_id
  ,p_position_id                   => p_position_id
  ,p_people_group_id               => p_people_group_id
  ,p_cost_allocation_keyflex_id    => l_cost_allocation_id
  ,p_organization_id               => p_organization_id
  ,p_location_id                   => p_location_id
  ,p_grade_id                      => p_grade_id
  ,p_balancing_keyflex_id          => l_bal_allocation_id
  ,p_element_set_id                => p_element_set_id
  ,p_pay_basis_id                  => p_pay_basis_id
  ,p_comments                      => p_comments
  ,p_employment_category           => p_employment_category
  ,p_qualifying_age                => l_qualifying_age
  ,p_qualifying_length_of_service  => l_qualifying_length_of_service
  ,p_qualifying_units              => l_qualifying_units
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
  ,p_element_link_id               => l_element_link_id
  ,p_object_version_number         => l_object_version_number
  ,p_effective_start_date          => l_effective_start_date
  ,p_effective_end_date            => l_effective_end_date
  ,p_comment_id                    => l_comment_id
  );

  -- The following three procedures are called to create the subsequent entries
  -- once element_link_id is created.

  -- Creates link input values for the element link created
  pay_pel_bus.chk_link_input_values
  (p_element_type_id => p_element_type_id
  ,p_element_link_id => l_element_link_id
  ,p_effective_date  => l_effective_date
  );

  --
  -- Set out variables
  --
  p_element_link_id            := l_element_link_id;
  p_comment_id                 := l_comment_id;
  p_object_version_number      := l_object_version_number;
  p_effective_start_date       := l_effective_start_date;
  p_effective_end_date         := l_effective_end_date;
  p_standard_link_flag         := l_standard_link_flag;
  p_cost_allocation_keyflex_id := l_cost_allocation_id;
  p_balancing_keyflex_id       := l_bal_allocation_id;

  hr_utility.set_location(' Leaving:'||l_proc, 70);
end create_element_link;

end pay_element_link_internal;

/
