--------------------------------------------------------
--  DDL for Package PAY_COST_ALLOCATIONS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_COST_ALLOCATIONS_F_PKG" AUTHID CURRENT_USER AS
/* $Header: pycsa01t.pkh 115.0 99/07/17 05:55:24 porting ship $ */
--
  procedure insert_row(p_rowid             in out varchar2,
                       p_cost_allocation_id    in number,
                       p_effective_start_date  in date,
                       p_effective_end_date    in date,
                       p_business_group_id     in number,
                       p_cost_allocation_keyflex_id in number,
                       p_assignment_id         in number,
                       p_proportion            in number,
                       p_request_id            in number,
                       p_program_application_id in number,
                       p_program_id            in number,
                       p_program_update_date   in date);
  --
  procedure update_row(p_rowid                in varchar2,
                       p_cost_allocation_id    in number,
                       p_effective_start_date  in date,
                       p_effective_end_date    in date,
                       p_business_group_id     in number,
                       p_cost_allocation_keyflex_id in number,
                       p_assignment_id         in number,
                       p_proportion            in number,
                       p_request_id            in number,
                       p_program_application_id in number,
                       p_program_id            in number,
                       p_program_update_date   in date);
  --
  procedure delete_row(p_rowid   in varchar2);
  --
  procedure lock_row(p_rowid                   in varchar2,
                       p_cost_allocation_id    in number,
                       p_effective_start_date  in date,
                       p_effective_end_date    in date,
                       p_business_group_id     in number,
                       p_cost_allocation_keyflex_id in number,
                       p_assignment_id         in number,
                       p_proportion            in number,
                       p_request_id            in number,
                       p_program_application_id in number,
                       p_program_id            in number,
                       p_program_update_date   in date);
  --
  procedure maintain_cost_keyflex(p_cost_keyflex_id in out number,
				  p_cost_keyflex_structure in varchar2,
				  p_cost_allocation_keyflex_id in number,
				  p_concatenated_segments in varchar2,
				  p_summary_flag in varchar2,
				  p_start_date_active in date,
				  p_end_date_active in date,
				  p_segment1 in varchar2,
				  p_segment2 in varchar2,
				  p_segment3 in varchar2,
				  p_segment4 in varchar2,
				  p_segment5 in varchar2,
				  p_segment6 in varchar2,
				  p_segment7 in varchar2,
				  p_segment8 in varchar2,
				  p_segment9 in varchar2,
				  p_segment10 in varchar2,
				  p_segment11 in varchar2,
				  p_segment12 in varchar2,
				  p_segment13 in varchar2,
				  p_segment14 in varchar2,
				  p_segment15 in varchar2,
				  p_segment16 in varchar2,
				  p_segment17 in varchar2,
				  p_segment18 in varchar2,
				  p_segment19 in varchar2,
				  p_segment20 in varchar2,
				  p_segment21 in varchar2,
				  p_segment22 in varchar2,
				  p_segment23 in varchar2,
				  p_segment24 in varchar2,
				  p_segment25 in varchar2,
				  p_segment26 in varchar2,
				  p_segment27 in varchar2,
				  p_segment28 in varchar2,
				  p_segment29 in varchar2,
				  p_segment30 in varchar2);
--
end PAY_COST_ALLOCATIONS_F_PKG;

 

/
