--------------------------------------------------------
--  DDL for Package PER_RI_WORKBENCH_ITEM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_WORKBENCH_ITEM_API" AUTHID CURRENT_USER AS
/* $Header: pewbiapi.pkh 115.0 2003/07/03 05:50:40 kavenkat noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_workbench_item >----------------------|
-- ----------------------------------------------------------------------------
--
Procedure create_workbench_item
  (   p_validate                       In  Boolean   Default False
     ,p_workbench_item_code            In  Varchar2
     ,p_workbench_item_name            In  Varchar2
     ,p_workbench_item_description     In  Varchar2
     ,p_menu_id                        In  Number
     ,p_workbench_item_sequence        In  Number
     ,p_workbench_parent_item_code     In  Varchar2
     ,p_workbench_item_creation_date   In  Date
     ,p_workbench_item_type            In  Varchar2
     ,p_language_code                  In  Varchar2  Default hr_api.userenv_lang
     ,p_effective_date                 In  Date
     ,p_object_version_number          Out Nocopy Number
  ) ;

-- ----------------------------------------------------------------------------
-- |-------------------------------< update_workbench_item >-------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_workbench_item
  (   p_validate                       In  Boolean   Default False
     ,p_workbench_item_code            In  Varchar2
     ,p_workbench_item_name            In  Varchar2  Default hr_api.g_varchar2
     ,p_workbench_item_description     In  Varchar2  Default hr_api.g_varchar2
     ,p_menu_id                        In  Number    Default hr_api.g_number
     ,p_workbench_item_sequence        In  Number    Default hr_api.g_number
     ,p_workbench_parent_item_code     In  Varchar2  Default hr_api.g_varchar2
     ,p_workbench_item_creation_date   In  Date      Default hr_api.g_date
     ,p_workbench_item_type            In  Varchar2  Default hr_api.g_varchar2
     ,p_language_code                  In  Varchar2  Default hr_api.userenv_lang
     ,p_effective_date                 In  Date
     ,p_object_version_number          In Out Nocopy Number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_workbench_item >------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_workbench_item
   (  p_validate                     In Boolean Default False
     ,p_workbench_item_code          In Varchar2
     ,p_object_version_number        IN Number );

End per_ri_workbench_item_api;
--

 

/
