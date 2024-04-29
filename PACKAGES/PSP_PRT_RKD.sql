--------------------------------------------------------
--  DDL for Package PSP_PRT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_PRT_RKD" AUTHID CURRENT_USER as
/* $Header: PSPRTRHS.pls 120.1 2005/07/05 23:50 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_template_id                  in number
  ,p_template_name_o              in varchar2
  ,p_business_group_id_o          in number
  ,p_set_of_books_id_o            in number
  ,p_object_version_number_o      in number
  ,p_report_type_o                in varchar2
  ,p_period_frequency_id_o        in number
  ,p_report_template_code_o       in varchar2
  ,p_display_all_emp_distrib_fl_o in varchar2
  ,p_manual_entry_override_flag_o in varchar2
  ,p_approval_type_o              in varchar2
  ,p_custom_approval_code_o       in varchar2
  ,p_sup_levels_o                 in number
  ,p_preview_effort_report_flag_o in varchar2
  ,p_notification_reminder_in_d_o in number
  ,p_sprcd_tolerance_amt_o        in number
  ,p_sprcd_tolerance_percent_o    in number
  ,p_description_o                in varchar2
  ,p_legislation_code_o           in varchar2
  ,p_hundred_pcent_eff_at_per_a_o in varchar2
  ,p_selection_match_level_o      in varchar2
  );
--
end psp_prt_rkd;

 

/