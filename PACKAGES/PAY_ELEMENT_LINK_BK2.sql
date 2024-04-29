--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_LINK_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_LINK_BK2" AUTHID CURRENT_USER as
/* $Header: pypelapi.pkh 120.3.12010000.1 2008/07/27 23:21:44 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_element_link_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_element_link_b
  (p_effective_date                  in     date
  ,p_element_link_id		     in     number
  ,p_datetrack_mode		     in     varchar2
  ,p_costable_type                   in     varchar2
  ,p_element_set_id                  in     number
  ,p_multiply_value_flag             in     varchar2
  ,p_standard_link_flag              in     varchar2
  ,p_transfer_to_gl_flag             in     varchar2
  ,p_comments                        in     varchar2
  ,p_comment_id                      in     varchar2
  ,p_employment_category             in     varchar2
  ,p_qualifying_age                  in     number
  ,p_qualifying_length_of_service    in     number
  ,p_qualifying_units                in     varchar2
  ,p_attribute_category              in     varchar2
  ,p_attribute1                      in     varchar2
  ,p_attribute2                      in     varchar2
  ,p_attribute3                      in     varchar2
  ,p_attribute4                      in     varchar2
  ,p_attribute5                      in     varchar2
  ,p_attribute6                      in     varchar2
  ,p_attribute7                      in     varchar2
  ,p_attribute8                      in     varchar2
  ,p_attribute9                      in     varchar2
  ,p_attribute10                     in     varchar2
  ,p_attribute11                     in     varchar2
  ,p_attribute12                     in     varchar2
  ,p_attribute13                     in     varchar2
  ,p_attribute14                     in     varchar2
  ,p_attribute15                     in     varchar2
  ,p_attribute16                     in     varchar2
  ,p_attribute17                     in     varchar2
  ,p_attribute18                     in     varchar2
  ,p_attribute19                     in     varchar2
  ,p_attribute20                     in     varchar2
  ,p_cost_segment1                   in     varchar2
  ,p_cost_segment2                   in     varchar2
  ,p_cost_segment3                   in     varchar2
  ,p_cost_segment4                   in     varchar2
  ,p_cost_segment5                   in     varchar2
  ,p_cost_segment6                   in     varchar2
  ,p_cost_segment7                   in     varchar2
  ,p_cost_segment8                   in     varchar2
  ,p_cost_segment9                   in     varchar2
  ,p_cost_segment10                  in     varchar2
  ,p_cost_segment11                  in     varchar2
  ,p_cost_segment12                  in     varchar2
  ,p_cost_segment13                  in     varchar2
  ,p_cost_segment14                  in     varchar2
  ,p_cost_segment15                  in     varchar2
  ,p_cost_segment16                  in     varchar2
  ,p_cost_segment17                  in     varchar2
  ,p_cost_segment18                  in     varchar2
  ,p_cost_segment19                  in     varchar2
  ,p_cost_segment20                  in     varchar2
  ,p_cost_segment21                  in     varchar2
  ,p_cost_segment22                  in     varchar2
  ,p_cost_segment23                  in     varchar2
  ,p_cost_segment24                  in     varchar2
  ,p_cost_segment25                  in     varchar2
  ,p_cost_segment26                  in     varchar2
  ,p_cost_segment27                  in     varchar2
  ,p_cost_segment28                  in     varchar2
  ,p_cost_segment29                  in     varchar2
  ,p_cost_segment30                  in     varchar2
  ,p_balance_segment1                in     varchar2
  ,p_balance_segment2                in     varchar2
  ,p_balance_segment3                in     varchar2
  ,p_balance_segment4                in     varchar2
  ,p_balance_segment5                in     varchar2
  ,p_balance_segment6                in     varchar2
  ,p_balance_segment7                in     varchar2
  ,p_balance_segment8                in     varchar2
  ,p_balance_segment9                in     varchar2
  ,p_balance_segment10               in     varchar2
  ,p_balance_segment11               in     varchar2
  ,p_balance_segment12               in     varchar2
  ,p_balance_segment13               in     varchar2
  ,p_balance_segment14               in     varchar2
  ,p_balance_segment15               in     varchar2
  ,p_balance_segment16               in     varchar2
  ,p_balance_segment17               in     varchar2
  ,p_balance_segment18               in     varchar2
  ,p_balance_segment19               in     varchar2
  ,p_balance_segment20               in     varchar2
  ,p_balance_segment21               in     varchar2
  ,p_balance_segment22               in     varchar2
  ,p_balance_segment23               in     varchar2
  ,p_balance_segment24               in     varchar2
  ,p_balance_segment25               in     varchar2
  ,p_balance_segment26               in     varchar2
  ,p_balance_segment27               in     varchar2
  ,p_balance_segment28               in     varchar2
  ,p_balance_segment29               in     varchar2
  ,p_balance_segment30               in     varchar2
  ,p_cost_concat_segments_in         in     varchar2
  ,p_balance_concat_segments_in      in     varchar2
  ,p_object_version_number	     in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_element_link_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_element_link_a
  (p_effective_date                  in     date
  ,p_element_link_id		     in     number
  ,p_datetrack_mode		     in     varchar2
  ,p_costable_type                   in     varchar2
  ,p_element_set_id                  in     number
  ,p_multiply_value_flag             in     varchar2
  ,p_standard_link_flag              in     varchar2
  ,p_transfer_to_gl_flag             in     varchar2
  ,p_comments                        in     varchar2
  ,p_comment_id                      in     varchar2
  ,p_employment_category             in     varchar2
  ,p_qualifying_age                  in     number
  ,p_qualifying_length_of_service    in     number
  ,p_qualifying_units                in     varchar2
  ,p_attribute_category              in     varchar2
  ,p_attribute1                      in     varchar2
  ,p_attribute2                      in     varchar2
  ,p_attribute3                      in     varchar2
  ,p_attribute4                      in     varchar2
  ,p_attribute5                      in     varchar2
  ,p_attribute6                      in     varchar2
  ,p_attribute7                      in     varchar2
  ,p_attribute8                      in     varchar2
  ,p_attribute9                      in     varchar2
  ,p_attribute10                     in     varchar2
  ,p_attribute11                     in     varchar2
  ,p_attribute12                     in     varchar2
  ,p_attribute13                     in     varchar2
  ,p_attribute14                     in     varchar2
  ,p_attribute15                     in     varchar2
  ,p_attribute16                     in     varchar2
  ,p_attribute17                     in     varchar2
  ,p_attribute18                     in     varchar2
  ,p_attribute19                     in     varchar2
  ,p_attribute20                     in     varchar2
  ,p_cost_segment1                   in     varchar2
  ,p_cost_segment2                   in     varchar2
  ,p_cost_segment3                   in     varchar2
  ,p_cost_segment4                   in     varchar2
  ,p_cost_segment5                   in     varchar2
  ,p_cost_segment6                   in     varchar2
  ,p_cost_segment7                   in     varchar2
  ,p_cost_segment8                   in     varchar2
  ,p_cost_segment9                   in     varchar2
  ,p_cost_segment10                  in     varchar2
  ,p_cost_segment11                  in     varchar2
  ,p_cost_segment12                  in     varchar2
  ,p_cost_segment13                  in     varchar2
  ,p_cost_segment14                  in     varchar2
  ,p_cost_segment15                  in     varchar2
  ,p_cost_segment16                  in     varchar2
  ,p_cost_segment17                  in     varchar2
  ,p_cost_segment18                  in     varchar2
  ,p_cost_segment19                  in     varchar2
  ,p_cost_segment20                  in     varchar2
  ,p_cost_segment21                  in     varchar2
  ,p_cost_segment22                  in     varchar2
  ,p_cost_segment23                  in     varchar2
  ,p_cost_segment24                  in     varchar2
  ,p_cost_segment25                  in     varchar2
  ,p_cost_segment26                  in     varchar2
  ,p_cost_segment27                  in     varchar2
  ,p_cost_segment28                  in     varchar2
  ,p_cost_segment29                  in     varchar2
  ,p_cost_segment30                  in     varchar2
  ,p_balance_segment1                in     varchar2
  ,p_balance_segment2                in     varchar2
  ,p_balance_segment3                in     varchar2
  ,p_balance_segment4                in     varchar2
  ,p_balance_segment5                in     varchar2
  ,p_balance_segment6                in     varchar2
  ,p_balance_segment7                in     varchar2
  ,p_balance_segment8                in     varchar2
  ,p_balance_segment9                in     varchar2
  ,p_balance_segment10               in     varchar2
  ,p_balance_segment11               in     varchar2
  ,p_balance_segment12               in     varchar2
  ,p_balance_segment13               in     varchar2
  ,p_balance_segment14               in     varchar2
  ,p_balance_segment15               in     varchar2
  ,p_balance_segment16               in     varchar2
  ,p_balance_segment17               in     varchar2
  ,p_balance_segment18               in     varchar2
  ,p_balance_segment19               in     varchar2
  ,p_balance_segment20               in     varchar2
  ,p_balance_segment21               in     varchar2
  ,p_balance_segment22               in     varchar2
  ,p_balance_segment23               in     varchar2
  ,p_balance_segment24               in     varchar2
  ,p_balance_segment25               in     varchar2
  ,p_balance_segment26               in     varchar2
  ,p_balance_segment27               in     varchar2
  ,p_balance_segment28               in     varchar2
  ,p_balance_segment29               in     varchar2
  ,p_balance_segment30               in     varchar2
  ,p_cost_concat_segments_in         in     varchar2
  ,p_balance_concat_segments_in      in     varchar2
  ,p_object_version_number	     in     number
  ,p_cost_allocation_keyflex_id      in     number
  ,p_balancing_keyflex_id            in     number
  ,p_cost_concat_segments_out        in     varchar2
  ,p_balance_concat_segments_out     in     varchar2
  ,p_effective_start_date	     in     date
  ,p_effective_end_date		     in     date
   );
end PAY_ELEMENT_LINK_bk2;

/
