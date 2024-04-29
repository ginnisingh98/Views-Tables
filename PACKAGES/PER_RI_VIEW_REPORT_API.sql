--------------------------------------------------------
--  DDL for Package PER_RI_VIEW_REPORT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_VIEW_REPORT_API" AUTHID CURRENT_USER AS
/* $Header: pervrapi.pkh 120.1 2006/06/12 23:58:02 ndorai noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_view_report >-------------------------|
-- ----------------------------------------------------------------------------
Procedure create_view_report
  (   p_validate                       In  Boolean   Default False
     ,p_workbench_view_report_code     In Varchar2
     ,p_workbench_view_report_name     In Varchar2
     ,p_wb_view_report_description     In Varchar2
     ,p_workbench_item_code            In Varchar2
     ,p_workbench_view_report_type     In Varchar2
     ,p_workbench_view_report_action   In Varchar2
     ,p_workbench_view_country         In Varchar2
     ,p_wb_view_report_instruction     In Varchar2
     ,p_language_code                  In  Varchar2  Default hr_api.userenv_lang
     ,p_effective_date                 In  Date
     ,p_object_version_number          Out Nocopy Number
     ,p_primary_industry	       In Varchar2
     ,p_enabled_flag               In Varchar2 Default 'Y'
  ) ;

-- ----------------------------------------------------------------------------
-- |-------------------------------< update_view_report >---------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_view_report
  (   p_validate                       In  Boolean   Default False
     ,p_workbench_view_report_code     In Varchar2
     ,p_workbench_view_report_name     In Varchar2   Default hr_api.g_varchar2
     ,p_wb_view_report_description     In Varchar2   Default hr_api.g_varchar2
     ,p_workbench_item_code            In Varchar2   Default hr_api.g_varchar2
     ,p_workbench_view_report_type     In Varchar2   Default hr_api.g_varchar2
     ,p_workbench_view_report_action   In Varchar2   Default hr_api.g_varchar2
     ,p_workbench_view_country         In Varchar2   Default hr_api.g_varchar2
     ,p_wb_view_report_instruction     In Varchar2   Default hr_api.g_varchar2
     ,p_language_code                  In  Varchar2  Default hr_api.userenv_lang
     ,p_effective_date                 In  Date
     ,p_object_version_number          In Out Nocopy Number
     ,p_primary_industry	       In Varchar2   Default hr_api.g_varchar2
     ,p_enabled_flag               In Varchar2 Default 'Y'
  ) ;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_view_report >--------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_view_report
   (  p_validate                     In Boolean Default False
     ,p_workbench_view_report_code   In Varchar2
     ,p_object_version_number        IN Number );

End per_ri_view_report_api;
--

 

/
