--------------------------------------------------------
--  DDL for Package HXC_ALIAS_TYPE_COMP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ALIAS_TYPE_COMP_API" AUTHID CURRENT_USER as
/* $Header: hxcatcapi.pkh 120.0 2005/05/29 05:26:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_alias_type_comp >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	 Creates alias type components.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--  p_validate                       No  boolean  If TRUE then the database
--                                                remains unchanged. If FALSE
--                                                then the alias type component
--                                                is not created. Default is FALSE.
-- p_component_name                 Yes   in      name of the component.
-- p_component_type                 Yes   in      Indicates the type of the component.
-- p_mapping_component_id           Yes   in      Id of the mapping component.
-- p_alias_type_id                  Yes   in      Id of the alias type associated.
--
--
-- Post Success:
--
--When the alias type is updated properly the following parameters are set.
--   Name                           Type     Description
-- p_alias_type_component_id         Out     Id of the mapping defined.
-- p_object_version_number           Out     Object version number of the
--					     mapping defined.

-- Post Failure:
-- Alias type component is not defined and raise an application error.

-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_alias_type_comp
  (p_validate                      in     boolean  default false
  ,p_component_name                in     varchar2
  ,p_component_type                in     varchar2
  ,p_mapping_component_id          in     number
  ,p_alias_type_id                 in     number
  ,p_alias_type_component_id       out nocopy    number
  ,p_object_version_number         out nocopy    number
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_alias_type_comp>--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	 Updates alias type components.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--  p_validate                       No  boolean  If TRUE then the database
--                                                remains unchanged. If FALSE
--                                                then the alias type component
--                                                is not updated. Default is FALSE.
-- p_component_name                 Yes   in      name of the component.
-- p_component_type                 Yes   in      Indicates the type of the component.
-- p_mapping_component_id           Yes   in      Id of the mapping component.
-- p_alias_type_id                  Yes   in      Id of the alias type associated.
-- p_alias_type_component_id        Yes   Out     Id of the mapping defined.
--
--
-- Post Success:
--
--When the alias type is updated properly the following parameters are set.
--   Name                           Type     Description

-- p_object_version_number           Out     Object version number of the
--					     mapping defined.

-- Post Failure:
-- Alias type component is not defined and raise an application error.

-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_alias_type_comp
  (p_validate                      in     boolean  default false
  ,p_component_name                in     varchar2
  ,p_component_type                in     varchar2
  ,p_mapping_component_id          in     number
  ,p_alias_type_id                 in     number
  ,p_alias_type_component_id       in     number
  ,p_object_version_number         in out nocopy    number
  );

-- ----------------------------------------------------------------------------
-- |--------------------------< delete_alias_type_comp>------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	 Deletes alias type components.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--  p_validate                       No  boolean  If TRUE then the database
--                                                remains unchanged. If FALSE
--                                                then the alias type component
--                                                is not updated. Default is FALSE.
--  p_alias_type_component_id        Yes  in      alias type component id of
--						  the alias type component to be
--						  deleted
--  p_object_version_number          Yes  in      Object version number of the
--					          mapping to be deleted.
--
-- Post Success:
--
-- Post Failure:
-- Alias type component is not deleted and raise an application error.

-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_alias_type_comp
  (p_validate                      in     boolean  default false
  ,p_alias_type_component_id       in    number
  ,p_object_version_number         in     number
  );

end hxc_alias_type_comp_api;

 

/
