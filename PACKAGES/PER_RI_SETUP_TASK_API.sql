--------------------------------------------------------
--  DDL for Package PER_RI_SETUP_TASK_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_SETUP_TASK_API" AUTHID CURRENT_USER AS
/* $Header: pestbapi.pkh 115.0 2003/07/03 06:23:03 kavenkat noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_setup_task >---------------------------|
-- ----------------------------------------------------------------------------
--
Procedure create_setup_task
  (p_validate                       In     Boolean  Default False
  ,p_setup_task_code                In     varchar2
  ,p_workbench_item_code            in     varchar2
  ,p_setup_task_name                In     Varchar2
  ,p_setup_task_description         In     Varchar2
  ,p_setup_task_sequence            in     number
  ,p_setup_task_status              in     varchar2 default null
  ,p_setup_task_creation_date       in     date     default null
  ,p_setup_task_last_mod_date       in     date     default null
  ,p_setup_task_type                in     varchar2 default null
  ,p_setup_task_action              in     varchar2 default null
  ,p_language_code                  In     Varchar2  Default hr_api.userenv_lang
  ,p_effective_date                 in     date
  ,p_object_version_number          out nocopy number
  ) ;

-- ----------------------------------------------------------------------------
-- |-------------------------------< update_setup_task >----------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_setup_task
 ( p_validate                     In  Boolean   Default False
  ,p_setup_task_code              in     varchar2
  ,p_workbench_item_code          in     varchar2  default hr_api.g_varchar2
  ,p_setup_task_name              In     Varchar2  default hr_api.g_varchar2
  ,p_setup_task_description       In     Varchar2  default hr_api.g_varchar2
  ,p_setup_task_sequence          in     number    default hr_api.g_number
  ,p_setup_task_status            in     varchar2  default hr_api.g_varchar2
  ,p_setup_task_creation_date     in     date      default hr_api.g_date
  ,p_setup_task_last_mod_date     in     date      default hr_api.g_date
  ,p_setup_task_type              in     varchar2  default hr_api.g_varchar2
  ,p_setup_task_action            in     varchar2  default hr_api.g_varchar2
  ,p_language_code                In     Varchar2  Default hr_api.userenv_lang
  ,p_effective_date               in     date
  ,p_object_version_number        In Out Nocopy Number
  ) ;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_setup_task >-----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_setup_task
  (p_validate                     In Boolean Default False
  ,p_setup_task_code              in     varchar2
  ,p_object_version_number        in     number
  );

End PER_RI_SETUP_TASK_API;
--

 

/
