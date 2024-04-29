--------------------------------------------------------
--  DDL for Package PSP_PRT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_PRT_RKI" AUTHID CURRENT_USER as
/* $Header: PSPRTRHS.pls 120.1 2005/07/05 23:50 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_template_id                  in number
  ,p_template_name                in varchar2
  ,p_business_group_id            in number
  ,p_set_of_books_id              in number
  ,p_object_version_number        in number
  ,p_report_type                  in varchar2
  ,p_period_frequency_id          in number
  ,p_report_template_code         in varchar2
  ,p_display_all_emp_distrib_flag in varchar2
  ,p_manual_entry_override_flag   in varchar2
  ,p_approval_type                in varchar2
  ,p_custom_approval_code         in varchar2
  ,p_sup_levels                   in number
  ,p_preview_effort_report_flag   in varchar2
  ,p_notification_reminder_in_day in number
  ,p_sprcd_tolerance_amt          in number
  ,p_sprcd_tolerance_percent      in number
  ,p_description                  in varchar2
  ,p_legislation_code             in varchar2
  ,p_hundred_pcent_eff_at_per_asg in varchar2
  ,p_selection_match_level        in varchar2
  );
end psp_prt_rki;

 

/
