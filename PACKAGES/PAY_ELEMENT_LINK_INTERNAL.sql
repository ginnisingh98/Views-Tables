--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_LINK_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_LINK_INTERNAL" AUTHID CURRENT_USER as
/* $Header: pypelbsi.pkh 120.0 2006/10/05 13:24:58 thabara noship $ */

--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_element_link >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_element_link
  (p_effective_date                  in     date
  ,p_element_type_id                 in     number
  ,p_business_group_id               in     number
  ,p_costable_type                   in     varchar2
  ,p_payroll_id                      in     number   default null
  ,p_job_id                          in     number   default null
  ,p_position_id                     in     number   default null
  ,p_people_group_id                 in     number   default null
  ,p_cost_allocation_keyflex_id      in out nocopy number
  ,p_organization_id                 in     number   default null
  ,p_location_id                     in     number   default null
  ,p_grade_id                        in     number   default null
  ,p_balancing_keyflex_id            in out nocopy number
  ,p_element_set_id                  in     number   default null
  ,p_pay_basis_id                    in     number   default null
  ,p_link_to_all_payrolls_flag       in     varchar2 default 'N'
  ,p_standard_link_flag              in out nocopy varchar2
  ,p_transfer_to_gl_flag             in     varchar2 default 'N'
  ,p_comments                        in     varchar2 default null
  ,p_employment_category             in     varchar2 default null
  ,p_qualifying_age                  in     number   default null
  ,p_qualifying_length_of_service    in     number   default null
  ,p_qualifying_units                in     varchar2 default null
  ,p_attribute_category              in     varchar2 default null
  ,p_attribute1                      in     varchar2 default null
  ,p_attribute2                      in     varchar2 default null
  ,p_attribute3                      in     varchar2 default null
  ,p_attribute4                      in     varchar2 default null
  ,p_attribute5                      in     varchar2 default null
  ,p_attribute6                      in     varchar2 default null
  ,p_attribute7                      in     varchar2 default null
  ,p_attribute8                      in     varchar2 default null
  ,p_attribute9                      in     varchar2 default null
  ,p_attribute10                     in     varchar2 default null
  ,p_attribute11                     in     varchar2 default null
  ,p_attribute12                     in     varchar2 default null
  ,p_attribute13                     in     varchar2 default null
  ,p_attribute14                     in     varchar2 default null
  ,p_attribute15                     in     varchar2 default null
  ,p_attribute16                     in     varchar2 default null
  ,p_attribute17                     in     varchar2 default null
  ,p_attribute18                     in     varchar2 default null
  ,p_attribute19                     in     varchar2 default null
  ,p_attribute20                     in     varchar2 default null
  ,p_cost_segment1                   in     varchar2 default null
  ,p_cost_segment2                   in     varchar2 default null
  ,p_cost_segment3                   in     varchar2 default null
  ,p_cost_segment4                   in     varchar2 default null
  ,p_cost_segment5                   in     varchar2 default null
  ,p_cost_segment6                   in     varchar2 default null
  ,p_cost_segment7                   in     varchar2 default null
  ,p_cost_segment8                   in     varchar2 default null
  ,p_cost_segment9                   in     varchar2 default null
  ,p_cost_segment10                  in     varchar2 default null
  ,p_cost_segment11                  in     varchar2 default null
  ,p_cost_segment12                  in     varchar2 default null
  ,p_cost_segment13                  in     varchar2 default null
  ,p_cost_segment14                  in     varchar2 default null
  ,p_cost_segment15                  in     varchar2 default null
  ,p_cost_segment16                  in     varchar2 default null
  ,p_cost_segment17                  in     varchar2 default null
  ,p_cost_segment18                  in     varchar2 default null
  ,p_cost_segment19                  in     varchar2 default null
  ,p_cost_segment20                  in     varchar2 default null
  ,p_cost_segment21                  in     varchar2 default null
  ,p_cost_segment22                  in     varchar2 default null
  ,p_cost_segment23                  in     varchar2 default null
  ,p_cost_segment24                  in     varchar2 default null
  ,p_cost_segment25                  in     varchar2 default null
  ,p_cost_segment26                  in     varchar2 default null
  ,p_cost_segment27                  in     varchar2 default null
  ,p_cost_segment28                  in     varchar2 default null
  ,p_cost_segment29                  in     varchar2 default null
  ,p_cost_segment30                  in     varchar2 default null
  ,p_balance_segment1                in     varchar2 default null
  ,p_balance_segment2                in     varchar2 default null
  ,p_balance_segment3                in     varchar2 default null
  ,p_balance_segment4                in     varchar2 default null
  ,p_balance_segment5                in     varchar2 default null
  ,p_balance_segment6                in     varchar2 default null
  ,p_balance_segment7                in     varchar2 default null
  ,p_balance_segment8                in     varchar2 default null
  ,p_balance_segment9                in     varchar2 default null
  ,p_balance_segment10               in     varchar2 default null
  ,p_balance_segment11               in     varchar2 default null
  ,p_balance_segment12               in     varchar2 default null
  ,p_balance_segment13               in     varchar2 default null
  ,p_balance_segment14               in     varchar2 default null
  ,p_balance_segment15               in     varchar2 default null
  ,p_balance_segment16               in     varchar2 default null
  ,p_balance_segment17               in     varchar2 default null
  ,p_balance_segment18               in     varchar2 default null
  ,p_balance_segment19               in     varchar2 default null
  ,p_balance_segment20               in     varchar2 default null
  ,p_balance_segment21               in     varchar2 default null
  ,p_balance_segment22               in     varchar2 default null
  ,p_balance_segment23               in     varchar2 default null
  ,p_balance_segment24               in     varchar2 default null
  ,p_balance_segment25               in     varchar2 default null
  ,p_balance_segment26               in     varchar2 default null
  ,p_balance_segment27               in     varchar2 default null
  ,p_balance_segment28               in     varchar2 default null
  ,p_balance_segment29               in     varchar2 default null
  ,p_balance_segment30               in     varchar2 default null
  ,p_cost_concat_segments            in     varchar2
  ,p_balance_concat_segments         in     varchar2
  ,p_element_link_id		     out nocopy    number
  ,p_comment_id			     out nocopy    number
  ,p_object_version_number	     out nocopy    number
  ,p_effective_start_date	     out nocopy    date
  ,p_effective_end_date		     out nocopy    date
  );

end pay_element_link_internal;

/
