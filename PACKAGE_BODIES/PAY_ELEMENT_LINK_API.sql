--------------------------------------------------------
--  DDL for Package Body PAY_ELEMENT_LINK_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ELEMENT_LINK_API" as
/* $Header: pypelapi.pkb 120.3.12010000.1 2008/07/27 23:21:41 appldev ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'pay_element_link_api';
--
-- ----------------------------------------------------------------------------
-- |--------------------------<create_element_link>--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_element_link
  (p_validate                        in     boolean    default false
  ,p_effective_date                  in     date
  ,p_element_type_id                 in     number
  ,p_business_group_id               in     number
  ,p_costable_type                   in     varchar2
  ,p_payroll_id                      in     number     default null
  ,p_job_id                          in     number     default null
  ,p_position_id                     in     number     default null
  ,p_people_group_id                 in     number     default null
  ,p_cost_allocation_keyflex_id      in     number     default null
  ,p_organization_id                 in     number     default null
  ,p_location_id                     in     number     default null
  ,p_grade_id                        in     number     default null
  ,p_balancing_keyflex_id            in     number     default null
  ,p_element_set_id                  in     number     default null
  ,p_pay_basis_id                    in     number     default null
  ,p_link_to_all_payrolls_flag       in     varchar2   default 'N'
  ,p_standard_link_flag              in     varchar2   default null
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

  l_standard_link_flag  pay_element_links_f.standard_link_flag%type
                               := p_standard_link_flag;
  l_cost_allocation_id  number := p_cost_allocation_keyflex_id;
  l_bal_allocation_id   number := p_balancing_keyflex_id;

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
  -- Issue a savepoint
  --
  savepoint create_element_link;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    pay_element_link_BK1.create_element_link_b
      (p_effective_date               => l_effective_date
      ,p_element_type_id              => p_element_type_id
      ,p_business_group_id            => p_business_group_id
      ,p_costable_type                => p_costable_type
      ,p_payroll_id                   => p_payroll_id
      ,p_job_id                       => p_job_id
      ,p_position_id                  => p_position_id
      ,p_people_group_id              => p_people_group_id
      ,p_cost_allocation_keyflex_id   => l_cost_allocation_id
      ,p_organization_id              => p_organization_id
      ,p_location_id                  => p_location_id
      ,p_grade_id                     => p_grade_id
      ,p_balancing_keyflex_id         => l_bal_allocation_id
      ,p_element_set_id               => p_element_set_id
      ,p_pay_basis_id                 => p_pay_basis_id
      ,p_link_to_all_payrolls_flag    => p_link_to_all_payrolls_flag
      ,p_standard_link_flag           => l_standard_link_flag
      ,p_transfer_to_gl_flag          => p_transfer_to_gl_flag
      ,p_comments                     => p_comments
      ,p_employment_category          => p_employment_category
      ,p_qualifying_age               => p_qualifying_age
      ,p_qualifying_length_of_service => p_qualifying_length_of_service
      ,p_qualifying_units             => p_qualifying_units
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
      ,p_cost_segment1                => p_cost_segment1
      ,p_cost_segment2                => p_cost_segment2
      ,p_cost_segment3                => p_cost_segment3
      ,p_cost_segment4                => p_cost_segment4
      ,p_cost_segment5                => p_cost_segment5
      ,p_cost_segment6                => p_cost_segment6
      ,p_cost_segment7                => p_cost_segment7
      ,p_cost_segment8                => p_cost_segment8
      ,p_cost_segment9                => p_cost_segment9
      ,p_cost_segment10               => p_cost_segment10
      ,p_cost_segment11               => p_cost_segment11
      ,p_cost_segment12               => p_cost_segment12
      ,p_cost_segment13               => p_cost_segment13
      ,p_cost_segment14               => p_cost_segment14
      ,p_cost_segment15               => p_cost_segment15
      ,p_cost_segment16               => p_cost_segment16
      ,p_cost_segment17               => p_cost_segment17
      ,p_cost_segment18               => p_cost_segment18
      ,p_cost_segment19               => p_cost_segment19
      ,p_cost_segment20               => p_cost_segment20
      ,p_cost_segment21               => p_cost_segment21
      ,p_cost_segment22               => p_cost_segment22
      ,p_cost_segment23               => p_cost_segment23
      ,p_cost_segment24               => p_cost_segment24
      ,p_cost_segment25               => p_cost_segment25
      ,p_cost_segment26               => p_cost_segment26
      ,p_cost_segment27               => p_cost_segment27
      ,p_cost_segment28               => p_cost_segment28
      ,p_cost_segment29               => p_cost_segment29
      ,p_cost_segment30               => p_cost_segment30
      ,p_balance_segment1             => p_balance_segment1
      ,p_balance_segment2             => p_balance_segment2
      ,p_balance_segment3             => p_balance_segment3
      ,p_balance_segment4             => p_balance_segment4
      ,p_balance_segment5             => p_balance_segment5
      ,p_balance_segment6             => p_balance_segment6
      ,p_balance_segment7             => p_balance_segment7
      ,p_balance_segment8             => p_balance_segment8
      ,p_balance_segment9             => p_balance_segment9
      ,p_balance_segment10            => p_balance_segment10
      ,p_balance_segment11            => p_balance_segment11
      ,p_balance_segment12            => p_balance_segment12
      ,p_balance_segment13            => p_balance_segment13
      ,p_balance_segment14            => p_balance_segment14
      ,p_balance_segment15            => p_balance_segment15
      ,p_balance_segment16            => p_balance_segment16
      ,p_balance_segment17            => p_balance_segment17
      ,p_balance_segment18            => p_balance_segment18
      ,p_balance_segment19            => p_balance_segment19
      ,p_balance_segment20            => p_balance_segment20
      ,p_balance_segment21            => p_balance_segment21
      ,p_balance_segment22            => p_balance_segment22
      ,p_balance_segment23            => p_balance_segment23
      ,p_balance_segment24            => p_balance_segment24
      ,p_balance_segment25            => p_balance_segment25
      ,p_balance_segment26            => p_balance_segment26
      ,p_balance_segment27            => p_balance_segment27
      ,p_balance_segment28            => p_balance_segment28
      ,p_balance_segment29            => p_balance_segment29
      ,p_balance_segment30            => p_balance_segment30
      ,p_cost_concat_segments         => p_cost_concat_segments
      ,p_balance_concat_segments      => p_balance_concat_segments
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_element_link'
        ,p_hook_type   => 'BP'
        );
  end;

  hr_utility.set_location(l_proc, 20);
  --
  -- The main creation process has been moved to pypelbsi.pkb.
  --
  pay_element_link_internal.create_element_link
    (p_effective_date               => l_effective_date
    ,p_element_type_id              => p_element_type_id
    ,p_business_group_id            => p_business_group_id
    ,p_costable_type                => p_costable_type
    ,p_payroll_id                   => p_payroll_id
    ,p_job_id                       => p_job_id
    ,p_position_id                  => p_position_id
    ,p_people_group_id              => p_people_group_id
    ,p_cost_allocation_keyflex_id   => l_cost_allocation_id
    ,p_organization_id              => p_organization_id
    ,p_location_id                  => p_location_id
    ,p_grade_id                     => p_grade_id
    ,p_balancing_keyflex_id         => l_bal_allocation_id
    ,p_element_set_id               => p_element_set_id
    ,p_pay_basis_id                 => p_pay_basis_id
    ,p_link_to_all_payrolls_flag    => p_link_to_all_payrolls_flag
    ,p_standard_link_flag           => l_standard_link_flag
    ,p_transfer_to_gl_flag          => p_transfer_to_gl_flag
    ,p_comments                     => p_comments
    ,p_employment_category          => p_employment_category
    ,p_qualifying_age               => p_qualifying_age
    ,p_qualifying_length_of_service => p_qualifying_length_of_service
    ,p_qualifying_units             => p_qualifying_units
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
    ,p_cost_segment1                => p_cost_segment1
    ,p_cost_segment2                => p_cost_segment2
    ,p_cost_segment3                => p_cost_segment3
    ,p_cost_segment4                => p_cost_segment4
    ,p_cost_segment5                => p_cost_segment5
    ,p_cost_segment6                => p_cost_segment6
    ,p_cost_segment7                => p_cost_segment7
    ,p_cost_segment8                => p_cost_segment8
    ,p_cost_segment9                => p_cost_segment9
    ,p_cost_segment10               => p_cost_segment10
    ,p_cost_segment11               => p_cost_segment11
    ,p_cost_segment12               => p_cost_segment12
    ,p_cost_segment13               => p_cost_segment13
    ,p_cost_segment14               => p_cost_segment14
    ,p_cost_segment15               => p_cost_segment15
    ,p_cost_segment16               => p_cost_segment16
    ,p_cost_segment17               => p_cost_segment17
    ,p_cost_segment18               => p_cost_segment18
    ,p_cost_segment19               => p_cost_segment19
    ,p_cost_segment20               => p_cost_segment20
    ,p_cost_segment21               => p_cost_segment21
    ,p_cost_segment22               => p_cost_segment22
    ,p_cost_segment23               => p_cost_segment23
    ,p_cost_segment24               => p_cost_segment24
    ,p_cost_segment25               => p_cost_segment25
    ,p_cost_segment26               => p_cost_segment26
    ,p_cost_segment27               => p_cost_segment27
    ,p_cost_segment28               => p_cost_segment28
    ,p_cost_segment29               => p_cost_segment29
    ,p_cost_segment30               => p_cost_segment30
    ,p_balance_segment1             => p_balance_segment1
    ,p_balance_segment2             => p_balance_segment2
    ,p_balance_segment3             => p_balance_segment3
    ,p_balance_segment4             => p_balance_segment4
    ,p_balance_segment5             => p_balance_segment5
    ,p_balance_segment6             => p_balance_segment6
    ,p_balance_segment7             => p_balance_segment7
    ,p_balance_segment8             => p_balance_segment8
    ,p_balance_segment9             => p_balance_segment9
    ,p_balance_segment10            => p_balance_segment10
    ,p_balance_segment11            => p_balance_segment11
    ,p_balance_segment12            => p_balance_segment12
    ,p_balance_segment13            => p_balance_segment13
    ,p_balance_segment14            => p_balance_segment14
    ,p_balance_segment15            => p_balance_segment15
    ,p_balance_segment16            => p_balance_segment16
    ,p_balance_segment17            => p_balance_segment17
    ,p_balance_segment18            => p_balance_segment18
    ,p_balance_segment19            => p_balance_segment19
    ,p_balance_segment20            => p_balance_segment20
    ,p_balance_segment21            => p_balance_segment21
    ,p_balance_segment22            => p_balance_segment22
    ,p_balance_segment23            => p_balance_segment23
    ,p_balance_segment24            => p_balance_segment24
    ,p_balance_segment25            => p_balance_segment25
    ,p_balance_segment26            => p_balance_segment26
    ,p_balance_segment27            => p_balance_segment27
    ,p_balance_segment28            => p_balance_segment28
    ,p_balance_segment29            => p_balance_segment29
    ,p_balance_segment30            => p_balance_segment30
    ,p_cost_concat_segments         => p_cost_concat_segments
    ,p_balance_concat_segments      => p_balance_concat_segments
    ,p_element_link_id              => l_element_link_id
    ,p_comment_id                   => l_comment_id
    ,p_object_version_number        => l_object_version_number
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    );

  -- Creates assignment link usages if people group criteria is specified
  if p_people_group_id is not null then
    pay_pel_bus.chk_asg_link_usages
    (p_business_group_id    => p_business_group_id
    ,p_people_group_id      => p_people_group_id
    ,p_element_link_id      => l_element_link_id
    ,p_effective_start_date => l_effective_start_date
    ,p_effective_end_date   => l_effective_end_date
    );
  end if;

  -- Creates Standard Entries in case Standard link flag is 'Y'
  if l_standard_link_flag = 'Y' then
    pay_pel_bus.chk_standard_entries
    (p_business_group_id 		=> p_business_group_id
    ,p_element_link_id 			=> l_element_link_id
    ,p_element_type_id 			=> p_element_type_id
    ,p_effective_start_date 		=> l_effective_start_date
    ,p_effective_end_date 		=> l_effective_end_date
    ,p_payroll_id 			=> p_payroll_id
    ,p_link_to_all_payrolls_flag	=> p_link_to_all_payrolls_flag
    ,p_job_id   			=> p_job_id
    ,p_grade_id  			=> p_grade_id
    ,p_position_id 			=> p_position_id
    ,p_organization_id 			=> p_organization_id
    ,p_location_id     			=> p_location_id
    ,p_pay_basis_id      		=> p_pay_basis_id
    ,p_employment_category 		=> p_employment_category
    ,p_people_group_id    		=> p_people_group_id
    );
  end if;

  --
  -- Call After Process User Hook
  --
  begin
    pay_element_link_BK1.create_element_link_a
      (p_effective_date               => l_effective_date
      ,p_element_type_id              => p_element_type_id
      ,p_business_group_id            => p_business_group_id
      ,p_costable_type                => p_costable_type
      ,p_payroll_id                   => p_payroll_id
      ,p_job_id                       => p_job_id
      ,p_position_id                  => p_position_id
      ,p_people_group_id              => p_people_group_id
      ,p_cost_allocation_keyflex_id   => l_cost_allocation_id
      ,p_organization_id              => p_organization_id
      ,p_location_id                  => p_location_id
      ,p_grade_id                     => p_grade_id
      ,p_balancing_keyflex_id         => l_bal_allocation_id
      ,p_element_set_id               => p_element_set_id
      ,p_pay_basis_id                 => p_pay_basis_id
      ,p_link_to_all_payrolls_flag    => p_link_to_all_payrolls_flag
      ,p_standard_link_flag           => p_standard_link_flag
      ,p_transfer_to_gl_flag          => p_transfer_to_gl_flag
      ,p_comments                     => p_comments
      ,p_employment_category          => p_employment_category
      ,p_qualifying_age               => p_qualifying_age
      ,p_qualifying_length_of_service => p_qualifying_length_of_service
      ,p_qualifying_units             => p_qualifying_units
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
      ,p_cost_segment1                => p_cost_segment1
      ,p_cost_segment2                => p_cost_segment2
      ,p_cost_segment3                => p_cost_segment3
      ,p_cost_segment4                => p_cost_segment4
      ,p_cost_segment5                => p_cost_segment5
      ,p_cost_segment6                => p_cost_segment6
      ,p_cost_segment7                => p_cost_segment7
      ,p_cost_segment8                => p_cost_segment8
      ,p_cost_segment9                => p_cost_segment9
      ,p_cost_segment10               => p_cost_segment10
      ,p_cost_segment11               => p_cost_segment11
      ,p_cost_segment12               => p_cost_segment12
      ,p_cost_segment13               => p_cost_segment13
      ,p_cost_segment14               => p_cost_segment14
      ,p_cost_segment15               => p_cost_segment15
      ,p_cost_segment16               => p_cost_segment16
      ,p_cost_segment17               => p_cost_segment17
      ,p_cost_segment18               => p_cost_segment18
      ,p_cost_segment19               => p_cost_segment19
      ,p_cost_segment20               => p_cost_segment20
      ,p_cost_segment21               => p_cost_segment21
      ,p_cost_segment22               => p_cost_segment22
      ,p_cost_segment23               => p_cost_segment23
      ,p_cost_segment24               => p_cost_segment24
      ,p_cost_segment25               => p_cost_segment25
      ,p_cost_segment26               => p_cost_segment26
      ,p_cost_segment27               => p_cost_segment27
      ,p_cost_segment28               => p_cost_segment28
      ,p_cost_segment29               => p_cost_segment29
      ,p_cost_segment30               => p_cost_segment30
      ,p_balance_segment1             => p_balance_segment1
      ,p_balance_segment2             => p_balance_segment2
      ,p_balance_segment3             => p_balance_segment3
      ,p_balance_segment4             => p_balance_segment4
      ,p_balance_segment5             => p_balance_segment5
      ,p_balance_segment6             => p_balance_segment6
      ,p_balance_segment7             => p_balance_segment7
      ,p_balance_segment8             => p_balance_segment8
      ,p_balance_segment9             => p_balance_segment9
      ,p_balance_segment10            => p_balance_segment10
      ,p_balance_segment11            => p_balance_segment11
      ,p_balance_segment12            => p_balance_segment12
      ,p_balance_segment13            => p_balance_segment13
      ,p_balance_segment14            => p_balance_segment14
      ,p_balance_segment15            => p_balance_segment15
      ,p_balance_segment16            => p_balance_segment16
      ,p_balance_segment17            => p_balance_segment17
      ,p_balance_segment18            => p_balance_segment18
      ,p_balance_segment19            => p_balance_segment19
      ,p_balance_segment20            => p_balance_segment20
      ,p_balance_segment21            => p_balance_segment21
      ,p_balance_segment22            => p_balance_segment22
      ,p_balance_segment23            => p_balance_segment23
      ,p_balance_segment24            => p_balance_segment24
      ,p_balance_segment25            => p_balance_segment25
      ,p_balance_segment26            => p_balance_segment26
      ,p_balance_segment27            => p_balance_segment27
      ,p_balance_segment28            => p_balance_segment28
      ,p_balance_segment29            => p_balance_segment29
      ,p_balance_segment30            => p_balance_segment30
      ,p_cost_concat_segments         => p_cost_concat_segments
      ,p_balance_concat_segments      => p_balance_concat_segments
      ,p_element_link_id              => l_element_link_id
      ,p_comment_id                   => l_comment_id
      ,p_object_version_number        => l_object_version_number
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_element_link'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  --
  -- Set out variables
  --
  p_element_link_id        := l_element_link_id;
  p_comment_id             := l_comment_id;
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;

  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_element_link;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_element_link_id        := null;
    p_object_version_number  := null;


    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_element_link;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_element_link;
-- ----------------------------------------------------------------------------
-- |--------------------------<update_element_link>--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_element_link
  (p_validate                        in     boolean   default false
  ,p_effective_date                  in     date
  ,p_element_link_id		     in     number
  ,p_datetrack_mode		     in     varchar2
  ,p_costable_type                   in     varchar2  default hr_api.g_varchar2
  ,p_element_set_id                  in     number    default hr_api.g_number
  ,p_multiply_value_flag             in     varchar2  default hr_api.g_varchar2
  ,p_standard_link_flag              in     varchar2  default hr_api.g_varchar2
  ,p_transfer_to_gl_flag             in     varchar2  default hr_api.g_varchar2
  ,p_comments                        in     varchar2  default hr_api.g_varchar2
  ,p_comment_id                      in     varchar2  default hr_api.g_varchar2
  ,p_employment_category             in     varchar2  default hr_api.g_varchar2
  ,p_qualifying_age                  in     number    default hr_api.g_number
  ,p_qualifying_length_of_service    in     number    default hr_api.g_number
  ,p_qualifying_units                in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category              in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                      in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                      in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                      in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                      in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                      in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                      in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                      in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                      in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                      in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                     in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment1                   in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment2                   in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment3                   in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment4                   in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment5                   in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment6                   in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment7                   in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment8                   in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment9                   in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment10                  in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment11                  in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment12                  in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment13                  in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment14                  in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment15                  in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment16                  in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment17                  in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment18                  in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment19                  in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment20                  in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment21                  in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment22                  in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment23                  in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment24                  in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment25                  in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment26                  in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment27                  in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment28                  in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment29                  in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment30                  in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment1                in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment2                in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment3                in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment4                in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment5                in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment6                in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment7                in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment8                in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment9                in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment10               in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment11               in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment12               in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment13               in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment14               in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment15               in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment16               in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment17               in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment18               in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment19               in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment20               in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment21               in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment22               in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment23               in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment24               in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment25               in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment26               in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment27               in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment28               in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment29               in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment30               in     varchar2  default hr_api.g_varchar2
  ,p_cost_concat_segments_in         in     varchar2  default hr_api.g_varchar2
  ,p_balance_concat_segments_in      in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number	     in out nocopy number
  ,p_cost_allocation_keyflex_id      out nocopy    number
  ,p_balancing_keyflex_id            out nocopy    number
  ,p_cost_concat_segments_out        out nocopy    varchar2
  ,p_balance_concat_segments_out     out nocopy    varchar2
  ,p_effective_start_date	     out nocopy    date
  ,p_effective_end_date		     out nocopy    date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'update_element_link';
  l_effective_date      date;

  -- The variables to get the cost/balance id and structure number
  l_flex_num		number;
  l_cost_allocation_id  number;
  l_bal_allocation_id   number;

  -- cursor to fetch the current values of the element link record
    cursor csr_bg_et is
    select business_group_id
          ,element_type_id
	  ,standard_link_flag
   	  ,payroll_id
	  ,link_to_all_payrolls_flag
	  ,job_id
	  ,grade_id
	  ,position_id
	  ,organization_id
	  ,location_id
	  ,pay_basis_id
	  ,employment_category
	  ,people_group_id
    from  pay_element_links_f
    where element_link_id = p_element_link_id
    and   l_effective_date between effective_start_date
    and   effective_end_date;

  -- Cursor to get the structure number to be passed to get the cost/balance id
    cursor csr_flexnum(p_business_group_id number) is
    select cost_allocation_structure
    from   per_business_groups
    where  business_group_id = p_business_group_id;
  --
  l_element_link_rec  csr_bg_et%rowtype;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_element_link;
  --
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  open csr_bg_et;
  fetch csr_bg_et into l_element_link_rec;
  close csr_bg_et;
  --
  -- Call Before Process User Hook
  --
  begin
  pay_element_link_BK2.update_element_link_b
  (l_effective_date
  ,p_element_link_id
  ,p_datetrack_mode
  ,p_costable_type
  ,p_element_set_id
  ,p_multiply_value_flag
  ,p_standard_link_flag
  ,p_transfer_to_gl_flag
  ,p_comments
  ,p_comment_id
  ,p_employment_category
  ,p_qualifying_age
  ,p_qualifying_length_of_service
  ,p_qualifying_units
  ,p_attribute_category
  ,p_attribute1
  ,p_attribute2
  ,p_attribute3
  ,p_attribute4
  ,p_attribute5
  ,p_attribute6
  ,p_attribute7
  ,p_attribute8
  ,p_attribute9
  ,p_attribute10
  ,p_attribute11
  ,p_attribute12
  ,p_attribute13
  ,p_attribute14
  ,p_attribute15
  ,p_attribute16
  ,p_attribute17
  ,p_attribute18
  ,p_attribute19
  ,p_attribute20
  ,p_cost_segment1
  ,p_cost_segment2
  ,p_cost_segment3
  ,p_cost_segment4
  ,p_cost_segment5
  ,p_cost_segment6
  ,p_cost_segment7
  ,p_cost_segment8
  ,p_cost_segment9
  ,p_cost_segment10
  ,p_cost_segment11
  ,p_cost_segment12
  ,p_cost_segment13
  ,p_cost_segment14
  ,p_cost_segment15
  ,p_cost_segment16
  ,p_cost_segment17
  ,p_cost_segment18
  ,p_cost_segment19
  ,p_cost_segment20
  ,p_cost_segment21
  ,p_cost_segment22
  ,p_cost_segment23
  ,p_cost_segment24
  ,p_cost_segment25
  ,p_cost_segment26
  ,p_cost_segment27
  ,p_cost_segment28
  ,p_cost_segment29
  ,p_cost_segment30
  ,p_balance_segment1
  ,p_balance_segment2
  ,p_balance_segment3
  ,p_balance_segment4
  ,p_balance_segment5
  ,p_balance_segment6
  ,p_balance_segment7
  ,p_balance_segment8
  ,p_balance_segment9
  ,p_balance_segment10
  ,p_balance_segment11
  ,p_balance_segment12
  ,p_balance_segment13
  ,p_balance_segment14
  ,p_balance_segment15
  ,p_balance_segment16
  ,p_balance_segment17
  ,p_balance_segment18
  ,p_balance_segment19
  ,p_balance_segment20
  ,p_balance_segment21
  ,p_balance_segment22
  ,p_balance_segment23
  ,p_balance_segment24
  ,p_balance_segment25
  ,p_balance_segment26
  ,p_balance_segment27
  ,p_balance_segment28
  ,p_balance_segment29
  ,p_balance_segment30
  ,p_cost_concat_segments_in
  ,p_balance_concat_segments_in
  ,p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_element_link'
        ,p_hook_type   => 'BP'
        );
  end;
--
-- If the costable type is Distributed/Costed/Fixed Costed then call
-- hr_kflex_utility for mandatory balancing segments

  if (p_costable_type = 'D' or p_costable_type = 'C'
     or p_costable_type = 'F') then

      hr_utility.set_location('Entering:'|| l_proc, 30);

      -- Get the structure number for the business_group id supplied
        open csr_Flexnum(l_element_link_rec.business_group_id);
        fetch csr_Flexnum into l_flex_num;
        if csr_Flexnum%notfound then
          close csr_Flexnum;
          hr_utility.set_message(801,'HR_7471_FLEX_PEA_INVALID_ID');
          hr_utility.raise_error;
        end if;

      	hr_kflex_utility.upd_or_sel_keyflex_comb
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
	,p_concat_segments_in  => p_balance_concat_segments_in
	,p_ccid                => l_bal_allocation_id
	,p_concat_segments_out => p_balance_concat_segments_out
	);

     -- Call the hr_kflex_untility for optional costing if that info is
     -- supplied
     if (p_cost_segment1 is not null or p_cost_segment2 is not null or
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

	hr_kflex_utility.upd_or_sel_keyflex_comb
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
	,p_concat_segments_in  => p_cost_concat_segments_in
	,p_ccid                => l_cost_allocation_id
	,p_concat_segments_out => p_cost_concat_segments_out
	);
   end if;

 end if;
  --
  l_cost_allocation_id := nvl(l_cost_allocation_id,hr_api.g_number);
  l_bal_allocation_id := nvl(l_bal_allocation_id,hr_api.g_number);
  --
  -- Process Logic
  --
  pay_pel_upd.upd(
   p_effective_date		=> l_effective_date
  ,p_element_type_id		=> l_element_link_rec.element_type_id
  ,p_business_group_id		=> l_element_link_rec.business_group_id
  ,p_costable_type		=> p_costable_type
  ,p_multiply_value_flag	=> p_multiply_value_flag
  ,p_standard_link_flag		=> p_standard_link_flag
  ,p_transfer_to_gl_flag	=> p_transfer_to_gl_flag
  ,p_cost_allocation_keyflex_id => l_cost_allocation_id
  ,p_balancing_keyflex_id       => l_bal_allocation_id
  ,p_element_set_id		=> p_element_set_id
  ,p_comments			=> p_comments
  ,p_employment_category	=> p_employment_category
  ,p_qualifying_age		=> p_qualifying_age
  ,p_qualifying_length_of_service =>  p_qualifying_length_of_service
  ,p_qualifying_units		=> p_qualifying_units
  ,p_attribute_category		=> p_attribute_category
  ,p_attribute1			=> p_attribute1
  ,p_attribute2			=> p_attribute2
  ,p_attribute3			=> p_attribute3
  ,p_attribute4			=> p_attribute4
  ,p_attribute5			=> p_attribute5
  ,p_attribute6			=> p_attribute6
  ,p_attribute7			=> p_attribute7
  ,p_attribute8			=> p_attribute8
  ,p_attribute9			=> p_attribute9
  ,p_attribute10		=> p_attribute10
  ,p_attribute11		=> p_attribute11
  ,p_attribute12		=> p_attribute12
  ,p_attribute13		=> p_attribute13
  ,p_attribute14		=> p_attribute14
  ,p_attribute15		=> p_attribute15
  ,p_attribute16		=> p_attribute16
  ,p_attribute17		=> p_attribute17
  ,p_attribute18		=> p_attribute18
  ,p_attribute19		=> p_attribute19
  ,p_attribute20		=> p_attribute20
  ,p_element_link_id		=> p_element_link_id
  ,p_datetrack_mode		=> p_datetrack_mode
  ,p_object_version_number	=> p_object_version_number
  ,p_effective_start_date	=> p_effective_start_date
  ,p_effective_end_date		=> p_effective_end_date
);
--
-- Create element entries if the standard_link_flag is changed from 'N' to 'Y',
-- with the following conditions -
--   1. Entries for the link should not exist.
--   2. All required input values should have a default value.
--
if ((l_element_link_rec.standard_link_flag = 'N' and
     p_standard_link_flag = 'Y')) and
   (NOT pay_element_links_pkg.element_entries_exist(p_element_link_id,
                                                    TRUE))
then
  --
  pay_link_input_values_pkg.check_required_defaults
   (p_element_link_id,
    p_effective_date);
  --
  pay_pel_bus.chk_standard_entries
   (p_business_group_id 	=> l_element_link_rec.business_group_id
   ,p_element_link_id 		=> p_element_link_id
   ,p_element_type_id 		=> l_element_link_rec.element_type_id
   ,p_effective_start_date 	=> p_effective_start_date
   ,p_effective_end_date 	=> p_effective_end_date
   ,p_payroll_id 		=> l_element_link_rec.payroll_id
   ,p_link_to_all_payrolls_flag => l_element_link_rec.link_to_all_payrolls_flag
   ,p_job_id   		        => l_element_link_rec.job_id
   ,p_grade_id  		=> l_element_link_rec.grade_id
   ,p_position_id 		=> l_element_link_rec.position_id
   ,p_organization_id 		=> l_element_link_rec.organization_id
   ,p_location_id     		=> l_element_link_rec.location_id
   ,p_pay_basis_id      	=> l_element_link_rec.pay_basis_id
   ,p_employment_category 	=> l_element_link_rec.employment_category
   ,p_people_group_id    	=> l_element_link_rec.people_group_id
   );
  --
end if;
  --
  -- Call After Process User Hook
  --
begin
 pay_element_link_BK2.update_element_link_a
(l_effective_date
,p_element_link_id
,p_datetrack_mode
,p_costable_type
,p_element_set_id
,p_multiply_value_flag
,p_standard_link_flag
,p_transfer_to_gl_flag
,p_comments
,p_comment_id
,p_employment_category
,p_qualifying_age
,p_qualifying_length_of_service
,p_qualifying_units
,p_attribute_category
,p_attribute1
,p_attribute2
,p_attribute3
,p_attribute4
,p_attribute5
,p_attribute6
,p_attribute7
,p_attribute8
,p_attribute9
,p_attribute10
,p_attribute11
,p_attribute12
,p_attribute13
,p_attribute14
,p_attribute15
,p_attribute16
,p_attribute17
,p_attribute18
,p_attribute19
,p_attribute20
,p_cost_segment1
,p_cost_segment2
,p_cost_segment3
,p_cost_segment4
,p_cost_segment5
,p_cost_segment6
,p_cost_segment7
,p_cost_segment8
,p_cost_segment9
,p_cost_segment10
,p_cost_segment11
,p_cost_segment12
,p_cost_segment13
,p_cost_segment14
,p_cost_segment15
,p_cost_segment16
,p_cost_segment17
,p_cost_segment18
,p_cost_segment19
,p_cost_segment20
,p_cost_segment21
,p_cost_segment22
,p_cost_segment23
,p_cost_segment24
,p_cost_segment25
,p_cost_segment26
,p_cost_segment27
,p_cost_segment28
,p_cost_segment29
,p_cost_segment30
,p_balance_segment1
,p_balance_segment2
,p_balance_segment3
,p_balance_segment4
,p_balance_segment5
,p_balance_segment6
,p_balance_segment7
,p_balance_segment8
,p_balance_segment9
,p_balance_segment10
,p_balance_segment11
,p_balance_segment12
,p_balance_segment13
,p_balance_segment14
,p_balance_segment15
,p_balance_segment16
,p_balance_segment17
,p_balance_segment18
,p_balance_segment19
,p_balance_segment20
,p_balance_segment21
,p_balance_segment22
,p_balance_segment23
,p_balance_segment24
,p_balance_segment25
,p_balance_segment26
,p_balance_segment27
,p_balance_segment28
,p_balance_segment29
,p_balance_segment30
,p_cost_concat_segments_in
,p_balance_concat_segments_in
,p_object_version_number
,l_cost_allocation_id
,l_bal_allocation_id
,p_cost_concat_segments_out
,p_balance_concat_segments_out
,p_effective_start_date
,p_effective_end_date
);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_element_link'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_cost_allocation_keyflex_id := l_cost_allocation_id;
  p_balancing_keyflex_id       := l_bal_allocation_id;

  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_element_link;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_element_link;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_element_link;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_element_link_int >------------------------|
-- ----------------------------------------------------------------------------
procedure delete_element_link_int
  (p_effective_date                  in     date
  ,p_element_link_id                 in     number
  ,p_datetrack_delete_mode           in     varchar2
  ,p_object_version_number           in out nocopy number
  ,p_effective_start_date            out nocopy    date
  ,p_effective_end_date              out nocopy    date
  ,p_entries_warning                 out nocopy    boolean
)
is
--
  l_proc                        varchar2(72) := g_package||'delete_element_link_int';
  l_validation_start_date       date;
  l_validation_end_date         date;
  l_object_version_number       number:= p_object_version_number;
  l_effective_start_date        date;
  l_effective_end_date          date;
  l_entries_warning             boolean;
  l_liv_ovn                     number;
  l_liv_esd                     date;
  l_liv_eed                     date;
  l_business_group_id           number;
  l_people_group_id             number;
  l_old_esd                     date;
  l_old_eed                     date;
  l_old_min_esd                 date;
  l_old_max_eed                 date;
  l_new_min_esd                 date;
  l_new_max_eed                 date;
--
  cursor csr_links_entries is
    select  element_entry_id
    from    pay_element_entries_f
    where   element_link_id = p_element_link_id
    and     p_effective_date between effective_start_date
    and effective_end_date;

  cursor csr_all_inputs_for_link is
    select  link_input_value_id, object_version_number
    from    pay_link_input_values_f pliv
    where   element_link_id = p_element_link_id
    and     p_effective_date between effective_start_date
    and effective_end_date;

  cursor csr_last_liv is
    select  link_input_value_id
           ,object_version_number
           ,effective_start_date
           ,effective_end_date
    from    pay_link_input_values_f pliv
    where   element_link_id = p_element_link_id
    and     effective_end_date >= p_effective_date
    and     not exists
              (select null
               from pay_link_input_values_f pliv2
               where pliv2.element_link_id = pliv.element_link_id
               and pliv2.input_value_id = pliv.input_value_id
               and pliv2.effective_start_date > pliv.effective_start_date);

  cursor csr_link_date_range is
    select  min(effective_start_date) min_effective_start_date
           ,max(effective_end_date) max_effective_end_date
    from    pay_element_links_f
    where   element_link_id = p_element_link_id
    ;
 --
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Process Logic
  --
  -- 1) Lock the element link and identify the validation date range.
  -- 2) Validation in addition to the row handler.
  -- 3) Delete non datetrack child rows.
  -- 4) ZAP or End Date child rows.
  -- 5) Delete the element link.
  -- 6) Next Change or Future Change child rows.
  --

  --
  -- Ensure that the DateTrack delete mode is valid
  --
  dt_api.validate_dt_del_mode(p_datetrack_mode => p_datetrack_delete_mode);


  hr_utility.set_location(l_proc, 10);
  --
  -- 1) Lock the element link and identify the validation date range.
  --
  pay_pel_shd.lck
    (p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_delete_mode
    ,p_element_link_id                  => p_element_link_id
    ,p_object_version_number            => l_object_version_number
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    ,p_enforce_foreign_locking          => false
    );

  --
  -- Set the element link information obtained by the lock.
  --
  l_business_group_id := pay_pel_shd.g_old_rec.business_group_id;
  l_people_group_id   := pay_pel_shd.g_old_rec.people_group_id;
  l_old_esd           := pay_pel_shd.g_old_rec.effective_start_date;
  l_old_eed           := pay_pel_shd.g_old_rec.effective_end_date;

  --
  -- Remember the date range of the element link.
  --
  open csr_link_date_range;
  fetch csr_link_date_range into l_old_min_esd, l_old_max_eed;
  close csr_link_date_range;

  hr_utility.set_location(l_proc, 20);
  --
  -- 2) Validation in addition to the row handler.
  --
  -- Check to see if this delete is allowed.
  -- ie. We allow the cascade delete only when no element entry rows are
  -- to be deleted.
  --
  pay_pel_bus.chk_date_eff_delete
   (p_element_link_id       => p_element_link_id
   ,p_delete_mode           => p_datetrack_delete_mode
   ,p_validation_start_date => l_validation_start_date
   );

  hr_utility.set_location(l_proc, 30);
  --
  -- 3) Delete non datetrack child rows.
  -- Bug 5512101. Batch Element Link support.
  --
  if p_datetrack_delete_mode = hr_api.g_zap then
    -- Delete the batch object status.
    pay_batch_object_status_pkg.delete_object_status
      (p_object_type                  => 'EL'
      ,p_object_id                    => p_element_link_id
      ,p_payroll_action_id            => null
      );
  else
    -- Ensure that the batch object status is complete.
    pay_batch_object_status_pkg.chk_complete_status
      (p_object_type                  => 'EL'
      ,p_object_id                    => p_element_link_id
      );
  end if;

  hr_utility.set_location(l_proc, 40);
  --
  -- 4) ZAP or End Date child rows.
  --
  if p_datetrack_delete_mode in (hr_api.g_zap, hr_api.g_delete) then

    -- Delete element entries
    for fetched_entry in csr_links_entries
    loop
      hr_entry_api.delete_element_entry
      (p_datetrack_delete_mode,
       p_effective_date,
       fetched_entry.element_entry_id
       );
    end loop;

    -- Delete link input values
    for fetched_input_value in csr_all_inputs_for_link
    loop
      l_liv_ovn := fetched_input_value.object_version_number;
      l_liv_esd := null;
      l_liv_eed := null;
      pay_liv_del.del
        (p_effective_date        => p_effective_date
        ,p_datetrack_mode        => p_datetrack_delete_mode
        ,p_link_input_value_id   => fetched_input_value.link_input_value_id
        ,p_object_version_number => l_liv_ovn
        ,p_effective_start_date  => l_liv_esd
        ,p_effective_end_date    => l_liv_eed
        );
    end loop;

    -- Delete assignment link usuages
    pay_asg_link_usages_pkg.cascade_link_deletion
      (p_element_link_id       => p_element_link_id
      ,p_business_group_id     => l_business_group_id
      ,p_people_group_id       => l_people_group_id
      ,p_delete_mode           => p_datetrack_delete_mode
      ,p_effective_start_date  => l_old_esd
      ,p_effective_end_date    => l_old_eed
      ,p_validation_start_date => l_validation_start_date
      ,p_validation_end_date   => l_validation_end_date
      );

  end if;

  hr_utility.set_location(l_proc, 80);
  --
  -- 5) Delete the element link.
  --
  pay_pel_del.del
    (p_effective_date          => p_effective_date
    ,p_element_link_id         => p_element_link_id
    ,p_datetrack_delete_mode   => p_datetrack_delete_mode
    ,p_object_version_number   => l_object_version_number
    ,p_effective_start_date    => l_effective_start_date
    ,p_effective_end_date      => l_effective_end_date
    ,p_warning                 => l_entries_warning
    );

  hr_utility.set_location(l_proc, 90);
  --
  -- 6) Next Change or Future Change child rows.
  --
  if p_datetrack_delete_mode in (hr_api.g_delete_next_change
                                ,hr_api.g_future_change) then

    --
    -- We should extend the duration of child records only when
    -- the effective end date of the parent element link is extended.
    --

    -- Obtain the new date range.
    --
    open csr_link_date_range;
    fetch csr_link_date_range into l_new_min_esd, l_new_max_eed;
    close csr_link_date_range;

    if l_new_max_eed > l_old_max_eed then

      -- Delete assignment link usuages

      pay_asg_link_usages_pkg.cascade_link_deletion
        (p_element_link_id       => p_element_link_id
        ,p_business_group_id     => l_business_group_id
        ,p_people_group_id       => l_people_group_id
        ,p_delete_mode           => hr_api.g_delete_next_change
        ,p_effective_start_date  => l_new_min_esd
        ,p_effective_end_date    => l_new_max_eed
        ,p_validation_start_date => l_validation_start_date
        ,p_validation_end_date   => l_validation_end_date
        );

      -- Delete link input values
      --
      for last_liv_rec in csr_last_liv
      loop
        l_liv_ovn := last_liv_rec.object_version_number;
        l_liv_esd := null;
        l_liv_eed := null;
        if last_liv_rec.effective_end_date < l_new_max_eed then
          pay_liv_del.del
            (p_effective_date        => last_liv_rec.effective_end_date
            ,p_datetrack_mode        => hr_api.g_delete_next_change
            ,p_link_input_value_id   => last_liv_rec.link_input_value_id
            ,p_object_version_number => l_liv_ovn
            ,p_effective_start_date  => l_liv_esd
            ,p_effective_end_date    => l_liv_eed
            );
        end if;
      end loop;

      -- Delete element entries
      for fetched_entry in csr_links_entries
      loop
        hr_entry_api.delete_element_entry
        (p_datetrack_delete_mode,
         p_effective_date,
         fetched_entry.element_entry_id
         );
      end loop;

    end if;
  end if;

  --
  -- Set out variables
  --
  p_object_version_number           := l_object_version_number;
  p_effective_start_date            := l_effective_start_date;
  p_effective_end_date              := l_effective_end_date;
  p_entries_warning                 := l_entries_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
end delete_element_link_int;
--
-- ----------------------------------------------------------------------------
-- |--------------------------<delete_element_link> -------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_element_link
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_element_link_id		     in     number
  ,p_datetrack_delete_mode	     in     varchar2
  ,p_object_version_number	     in out nocopy number
  ,p_effective_start_date	     out nocopy    date
  ,p_effective_end_date		     out nocopy    date
  ,p_entries_warning		     out nocopy    boolean
) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_element_link';
  l_effective_date      date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_element_link;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
  pay_element_link_BK3.delete_element_link_b
  (l_effective_date
  ,p_element_link_id
  ,p_datetrack_delete_mode
  ,p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_element_link'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Validation in addition to Row Handlers
  --
  -- Bug 6004788. Replaced the call to pay_pel_del.del with call to
  -- delete_element_link_int.
  -- Process Logic
  --
  delete_element_link_int
  (p_effective_date         =>  l_effective_date
  ,p_element_link_id	    =>  p_element_link_id
  ,p_datetrack_delete_mode  => 	p_datetrack_delete_mode
  ,p_object_version_number  => 	p_object_version_number
  ,p_effective_start_date   => 	p_effective_start_date
  ,p_effective_end_date	    =>  p_effective_end_date
  ,p_entries_warning        =>  p_entries_warning
  );
  --
  -- Call After Process User Hook
  --
  begin
   pay_element_link_BK3.delete_element_link_a
  (l_effective_date
  ,p_element_link_id
  ,p_datetrack_delete_mode
  ,p_object_version_number
  ,p_effective_start_date
  ,p_effective_end_date
  ,p_entries_warning
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_element_link'
        ,p_hook_type   => 'AP'
        );
  end;

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_element_link;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_element_link;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_element_link;
--

end PAY_ELEMENT_LINK_API;

/
