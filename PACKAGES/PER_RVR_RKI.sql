--------------------------------------------------------
--  DDL for Package PER_RVR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RVR_RKI" AUTHID CURRENT_USER as
/* $Header: pervrrhi.pkh 120.2 2006/06/12 23:56:07 ndorai noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_workbench_item_code          in varchar2
  ,p_workbench_view_report_code   in varchar2
  ,p_workbench_view_report_type   in varchar2
  ,p_workbench_view_report_action in varchar2
  ,p_workbench_view_country       in varchar2
  ,p_wb_view_report_instruction   in varchar2
  ,p_object_version_number        in number
  ,p_primary_industry		      in varchar2
  ,p_enabled_flag                 in varchar2
  );
end per_rvr_rki;

 

/
