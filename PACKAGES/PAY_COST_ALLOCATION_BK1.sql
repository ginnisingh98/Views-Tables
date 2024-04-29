--------------------------------------------------------
--  DDL for Package PAY_COST_ALLOCATION_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_COST_ALLOCATION_BK1" AUTHID CURRENT_USER as
/* $Header: pycalapi.pkh 120.2 2005/11/11 07:06:59 adkumar noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_cost_allocation_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_cost_allocation_b
  (p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_proportion                    in     number
  ,p_business_group_id             in     number
  ,p_segment1                      in     varchar2
  ,p_segment2                      in     varchar2
  ,p_segment3                      in     varchar2
  ,p_segment4                      in     varchar2
  ,p_segment5                      in     varchar2
  ,p_segment6                      in     varchar2
  ,p_segment7                      in     varchar2
  ,p_segment8                      in     varchar2
  ,p_segment9                      in     varchar2
  ,p_segment10                     in     varchar2
  ,p_segment11                     in     varchar2
  ,p_segment12                     in     varchar2
  ,p_segment13                     in     varchar2
  ,p_segment14                     in     varchar2
  ,p_segment15                     in     varchar2
  ,p_segment16                     in     varchar2
  ,p_segment17                     in     varchar2
  ,p_segment18                     in     varchar2
  ,p_segment19                     in     varchar2
  ,p_segment20                     in     varchar2
  ,p_segment21                     in     varchar2
  ,p_segment22                     in     varchar2
  ,p_segment23                     in     varchar2
  ,p_segment24                     in     varchar2
  ,p_segment25                     in     varchar2
  ,p_segment26                     in     varchar2
  ,p_segment27                     in     varchar2
  ,p_segment28                     in     varchar2
  ,p_segment29                     in     varchar2
  ,p_segment30                     in     varchar2
  ,p_concat_segments               in     varchar2
  ,p_request_id                    in     number
  ,p_program_application_id        in     number
  ,p_program_id                    in     number
  ,p_program_update_date           in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_cost_allocation_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_cost_allocation_a
  (p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_proportion                    in     number
  ,p_business_group_id             in     number
  ,p_segment1                      in     varchar2
  ,p_segment2                      in     varchar2
  ,p_segment3                      in     varchar2
  ,p_segment4                      in     varchar2
  ,p_segment5                      in     varchar2
  ,p_segment6                      in     varchar2
  ,p_segment7                      in     varchar2
  ,p_segment8                      in     varchar2
  ,p_segment9                      in     varchar2
  ,p_segment10                     in     varchar2
  ,p_segment11                     in     varchar2
  ,p_segment12                     in     varchar2
  ,p_segment13                     in     varchar2
  ,p_segment14                     in     varchar2
  ,p_segment15                     in     varchar2
  ,p_segment16                     in     varchar2
  ,p_segment17                     in     varchar2
  ,p_segment18                     in     varchar2
  ,p_segment19                     in     varchar2
  ,p_segment20                     in     varchar2
  ,p_segment21                     in     varchar2
  ,p_segment22                     in     varchar2
  ,p_segment23                     in     varchar2
  ,p_segment24                     in     varchar2
  ,p_segment25                     in     varchar2
  ,p_segment26                     in     varchar2
  ,p_segment27                     in     varchar2
  ,p_segment28                     in     varchar2
  ,p_segment29                     in     varchar2
  ,p_segment30                     in     varchar2
  ,p_concat_segments               in     varchar2
  ,p_combination_name              in     varchar2
  ,p_request_id                    in     number
  ,p_program_application_id        in     number
  ,p_program_id                    in     number
  ,p_program_update_date           in     date
  ,p_cost_allocation_id            in     number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  ,p_object_version_number         in     number
  ,p_cost_allocation_keyflex_id    in     number
  );
--
end PAY_COST_ALLOCATION_BK1;

 

/
