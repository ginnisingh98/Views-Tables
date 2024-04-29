--------------------------------------------------------
--  DDL for Package PER_MM_POSITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_MM_POSITIONS_PKG" AUTHID CURRENT_USER as
/* $Header: pemmv02t.pkh 115.0 99/07/18 14:02:16 porting ship $ */
--
--
procedure update_row
             (p_select_position in varchar2,
              p_default_from in varchar2,
              p_deactivate_old_position in varchar2,
              p_new_position_definition_id in number,
              p_new_position_id in number,
              p_target_job_id in number,
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
              p_segment30 in varchar2,
              p_row_id in varchar2);
--
--
procedure load_rows
                 (p_mass_move_id in number,
                   p_business_group_id in number,
                   p_source_organization in varchar2,
                   p_session_date in date,
                   p_end_of_time in date,
                   p_position_name in varchar2,
                   p_job_name in varchar2,
                   p_attribute_category in varchar2,
                   p_attribute1 in varchar2,
                   p_attribute2 in varchar2,
                   p_attribute3 in varchar2,
                   p_attribute4 in varchar2,
                   p_attribute5 in varchar2,
                   p_attribute6 in varchar2,
                   p_attribute7 in varchar2,
                   p_attribute8 in varchar2,
                   p_attribute9 in varchar2,
                   p_attribute10 in varchar2,
                   p_attribute11 in varchar2,
                   p_attribute12 in varchar2,
                   p_attribute13 in varchar2,
                   p_attribute14 in varchar2,
                   p_attribute15 in varchar2,
                   p_attribute16 in varchar2,
                   p_attribute17 in varchar2,
                   p_attribute18 in varchar2,
                   p_attribute19 in varchar2,
                   p_attribute20 in varchar2);
--
--
procedure lock_row
             (p_mass_move_id in number,
              p_position_id in number,
              p_select_position in varchar2,
              p_default_from in varchar2,
              p_deactivate_old_position in varchar2,
              p_new_position_definition_id in number,
              p_new_position_id in number,
              p_target_job_id in number,
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
              p_segment30 in varchar2,
              p_row_id in varchar2);
--
--
procedure chk_org
         (p_new_organization_id in number,
          p_new_position_definition_id in number);
--
--
procedure get_job
         (p_new_position_definition_id in number,
          p_organization_id out number,
          p_new_position_id out number,
          p_target_job_name out varchar2,
          p_target_job_id out number,
          p_target_job_definition_id out number);
--
procedure get_target_job
         (p_new_job_id               in number,
          p_effective_date           in date,
          p_target_job_name          out varchar2,
          p_target_job_definition_id out number);
--

--
end  PER_MM_POSITIONS_PKG;


 

/
