--------------------------------------------------------
--  DDL for Package PSB_PARAMETER_FORMULAS_L_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_PARAMETER_FORMULAS_L_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBWPFLS.pls 120.2 2005/07/13 11:36:12 shtripat ship $ */

PROCEDURE LOCK_ROW (
  p_api_version                 in       number,
  p_init_msg_list               in       varchar2 := fnd_api.g_false,
  p_commit                      in       varchar2 := fnd_api.g_false,
  p_validation_level            in       number   := fnd_api.g_valid_level_full,
  p_return_status               OUT  NOCOPY      varchar2,
  p_msg_count                   OUT  NOCOPY      number,
  p_msg_data                    OUT  NOCOPY      varchar2,
  p_lock_row                    OUT  NOCOPY      varchar2,
  --
  p_rowid                       in varchar2,
  p_parameter_formula_id        in number,
  p_parameter_id                in number,
  p_step_number                 in number,
  p_budget_year_type_id         in number,
  p_balance_type                in varchar2,
  p_template_id                 in number,
  p_concatenated_segments       in varchar2,
  p_segment1                    in varchar2,
  p_segment2                    in varchar2,
  p_segment3                    in varchar2,
  p_segment4                    in varchar2,
  p_segment5                    in varchar2,
  p_segment6                    in varchar2,
  p_segment7                    in varchar2,
  p_segment8                    in varchar2,
  p_segment9                    in varchar2,
  p_segment10                   in varchar2,
  p_segment11                   in varchar2,
  p_segment12                   in varchar2,
  p_segment13                   in varchar2,
  p_segment14                   in varchar2,
  p_segment15                   in varchar2,
  p_segment16                   in varchar2,
  p_segment17                   in varchar2,
  p_segment18                   in varchar2,
  p_segment19                   in varchar2,
  p_segment20                   in varchar2,
  p_segment21                   in varchar2,
  p_segment22                   in varchar2,
  p_segment23                   in varchar2,
  p_segment24                   in varchar2,
  p_segment25                   in varchar2,
  p_segment26                   in varchar2,
  p_segment27                   in varchar2,
  p_segment28                   in varchar2,
  p_segment29                   in varchar2,
  p_segment30                   in varchar2,
  p_currency_code               in varchar2,
  p_amount                      in number,
  p_prefix_operator             in varchar2,
  p_postfix_operator            in varchar2,
  p_hiredate_between_from       in number,
  p_hiredate_between_to         in number,
  p_adjdate_between_from        in number,
  p_adjdate_between_to          in number,
  p_increment_by                in number,
  p_increment_type              in varchar2,
  p_assignment_type             in varchar2,
  p_attribute_id                in number,
  p_attribute_value             in varchar2,
  p_pay_element_id              in number,
  p_pay_element_option_id       in number,
  p_grade_step                  in number,
  p_element_value               in number,
  p_element_value_type          in varchar2,
  p_effective_start_date        in date,
  p_effective_end_date          in date,
  p_attribute1                  in varchar2,
  p_attribute2                  in varchar2,
  p_attribute3                  in varchar2,
  p_attribute4                  in varchar2,
  p_attribute5                  in varchar2,
  p_attribute6                  in varchar2,
  p_attribute7                  in varchar2,
  p_attribute8                  in varchar2,
  p_attribute9                  in varchar2,
  p_attribute10                 in varchar2,
  p_context                     in varchar2
  );


END PSB_PARAMETER_FORMULAS_L_PVT ;

 

/
