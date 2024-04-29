--------------------------------------------------------
--  DDL for Package PER_RI_SETUP_SUB_TASK_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_SETUP_SUB_TASK_API" AUTHID CURRENT_USER AS
/* $Header: pessbapi.pkh 115.1 2003/08/06 01:27:52 kavenkat noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_setup_sub_task >-----------------------|
-- ----------------------------------------------------------------------------
Procedure create_setup_sub_task
  (   p_validate                       In  Boolean   Default False
     ,p_setup_sub_task_code            In  Varchar2
     ,p_setup_sub_task_name	       In  Varchar2
     ,p_setup_sub_task_description     In  Varchar2
     ,p_setup_task_code                In  Varchar2
     ,p_setup_sub_task_sequence        In  Number
     ,p_setup_sub_task_status          In  Varchar2
     ,p_setup_sub_task_type            In  Varchar2
     ,p_setup_sub_task_dp_link         In  Varchar2
     ,p_setup_sub_task_action          In  Varchar2
     ,p_setup_sub_task_creation_date   In  Date
     ,p_setup_sub_task_last_mod_date   In  Date
     ,p_legislation_code               In Varchar2
     ,p_language_code                  In Varchar2 Default hr_api.userenv_lang
     ,p_effective_date                 In  Date
     ,p_object_version_number          Out Nocopy Number
  ) ;

-- ----------------------------------------------------------------------------
-- |-------------------------------< update_setup_sub_task >------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_setup_sub_task
  (   p_validate                       In  Boolean   Default False
     ,p_setup_sub_task_code            In  Varchar2
     ,p_setup_sub_task_name	       In  Varchar2  Default hr_api.g_varchar2
     ,p_setup_sub_task_description     In  Varchar2  Default hr_api.g_varchar2
     ,p_setup_task_code                In  Varchar2  Default hr_api.g_varchar2
     ,p_setup_sub_task_sequence        In  Number    Default hr_api.g_number
     ,p_setup_sub_task_status          In  Varchar2  Default hr_api.g_varchar2
     ,p_setup_sub_task_type            In  Varchar2  Default hr_api.g_varchar2
     ,p_setup_sub_task_dp_link         In  Varchar2  Default hr_api.g_varchar2
     ,p_setup_sub_task_action          In  Varchar2  Default hr_api.g_varchar2
     ,p_setup_sub_task_creation_date   In  Date      Default hr_api.g_date
     ,p_setup_sub_task_last_mod_date   In  Date      Default hr_api.g_date
     ,p_legislation_code               In  Varchar2  Default hr_api.g_varchar2
     ,p_language_code                  In  Varchar2  Default hr_api.userenv_lang
     ,p_effective_date                 In  Date
     ,p_object_version_number          In  Out Nocopy Number
  ) ;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_setup_sub_task >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_setup_sub_task
   (  p_validate                     In Boolean Default False
     ,p_setup_sub_task_code          In Varchar2
     ,p_object_version_number        IN Number );

End per_ri_setup_sub_task_api;
--

 

/
