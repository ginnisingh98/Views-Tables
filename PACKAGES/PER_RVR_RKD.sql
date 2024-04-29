--------------------------------------------------------
--  DDL for Package PER_RVR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RVR_RKD" AUTHID CURRENT_USER as
/* $Header: pervrrhi.pkh 120.2 2006/06/12 23:56:07 ndorai noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_workbench_view_report_code   in varchar2
  ,p_workbench_item_code_o        in varchar2
  ,p_workbench_view_report_type_o in varchar2
  ,p_workbench_view_report_acti_o in varchar2
  ,p_workbench_view_country_o     in varchar2
  ,p_wb_view_report_instruction_o in varchar2
  ,p_object_version_number_o      in number
  ,p_primary_industry_o		      in varchar2
  ,p_enabled_flag_o               in varchar2
  );
--
end per_rvr_rkd;

 

/
