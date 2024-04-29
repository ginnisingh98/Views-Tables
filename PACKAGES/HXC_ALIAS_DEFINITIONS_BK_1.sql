--------------------------------------------------------
--  DDL for Package HXC_ALIAS_DEFINITIONS_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ALIAS_DEFINITIONS_BK_1" AUTHID CURRENT_USER as
/* $Header: hxchadapi.pkh 120.0 2005/05/29 05:32:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_alias_definition_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_alias_definition_b
  (p_alias_definition_name         in     varchar2
  ,p_alias_context_code            in     varchar2
  ,p_business_group_id	           in     number
  ,p_legislation_code              in     varchar2
  ,p_description                   in     varchar2
  ,p_prompt                        in     varchar2
  ,p_timecard_field                in     varchar2
  ,p_language_code                 in     varchar2
  ,p_alias_type_id                 in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_alias_definition_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_alias_definition_a
  (p_alias_definition_id           in     number
  ,p_alias_definition_name         in     varchar2
  ,p_alias_context_code            in     varchar2
  ,p_business_group_id	           in     number
  ,p_legislation_code              in     varchar2
  ,p_description                   in     varchar2
  ,p_prompt                        in     varchar2
  ,p_timecard_field                in     varchar2
  ,p_object_version_number         in     number
  ,p_language_code                 in     varchar2
  ,p_alias_type_id                 in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_alias_definition_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_alias_definition_b
  (p_alias_definition_id           in     number
  ,p_alias_definition_name         in     varchar2
  ,p_alias_context_code            in     varchar2
  ,p_business_group_id	           in     number
  ,p_legislation_code              in     varchar2
  ,p_description                   in     varchar2
  ,p_prompt                        in     varchar2
  ,p_timecard_field                in     varchar2
  ,p_object_version_number         in     number
  ,p_language_code                 in     varchar2
  ,p_alias_type_id                 in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_alias_definition_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_alias_definition_a
  (p_alias_definition_id           in     number
  ,p_alias_definition_name         in     varchar2
  ,p_alias_context_code            in     varchar2
  ,p_business_group_id	           in     number
  ,p_legislation_code              in     varchar2
  ,p_description                   in     varchar2
  ,p_prompt                        in     varchar2
  ,p_timecard_field                in     varchar2
  ,p_object_version_number         in     number
  ,p_language_code                 in     varchar2
  ,p_alias_type_id                 in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_alias_definition_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_alias_definition_b
  (p_alias_definition_id           in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_alias_definition_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_alias_definition_a
  (p_alias_definition_id           in     number
  ,p_object_version_number         in     number
  );
--
end hxc_alias_definitions_bk_1;

 

/
