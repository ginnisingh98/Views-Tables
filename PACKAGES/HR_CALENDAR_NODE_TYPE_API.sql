--------------------------------------------------------
--  DDL for Package HR_CALENDAR_NODE_TYPE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CALENDAR_NODE_TYPE_API" AUTHID CURRENT_USER as
/* $Header: pepgtapi.pkh 120.0 2005/05/31 14:14:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_node_type >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API creates a generic hierarchy node type that is used for constructing
--   HRMS Calendar specifc generic hierarchy. It should not be used to create
--   other types of node type hierarchy nodes as it also creates lookup values
--   that are associated with calendar node types only.
--
--
-- Prerequisites:
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the node type is created.
--   p_effective_date               Yes  date     Application effective date.
--   p_hierarchy_type               Yes  varchar2 The type of hierarchy to which
--                                                the node will belong.
--   p_child_node_name              Yes  varchar2 The name of the node.
--   p_child_value_set              Yes  varchar2 The id of the valueset supplying
--                                                values for the node.
--   p_child_node_type                   varchar2 The lookup code of the node.
--   p_parent_node_type                  varchar2 The lookup code of the parent node.
--   p_description                       varchar2 Description of the node type.
--
-- Post Success:
--   The generic hierarchy node type record is created and the API sets the following out
--   parameters.
--
--   Name                           Type     Description
--   p_hier_node_type_id            number   If p_validate is false, uniquely
--                                           identifies the node type created.
--                                           If p_validate is true, set to
--                                           null.
--   p_object_version_number        number   If p_validate is false, set to
--                                           the version number of this
--                                           node type.
--                                           If p_validate is true, set to
--                                           null.
--
-- Post Failure:
--   The API does not create the generic hierarchy node type record and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--

procedure create_node_type
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_hierarchy_type                in     varchar2
  ,p_child_node_name               in     varchar2
  ,p_child_value_set               in     varchar2
  ,p_child_node_type               in     varchar2 default null
  ,p_parent_node_type              in     varchar2 default null
  ,p_description                   in     varchar2 default null
  ,p_hier_node_type_id                out nocopy  number
  ,p_object_version_number            out nocopy  number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_node_type >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API updates a generic hierarchy node type that is used for constructing
--   HRMS Calendar specifc generic hierarchy, as identified by p_hier_node_type_id.
--   It should not be used to update other types of node type hierarchy data as
--   it also updates lookup values that are associated with calendar node types
--   only.
--
-- Prerequisites:
--   The node type record identified by p_hier_node_type_id and
--   p_object_version_number must exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the node type  is updated.
--   p_effective_date               Yes  date     Application effective date.
--   p_hier_node_type_id            Yes  number   Surrogate id of the node type
--   p_object_version_number        Yes  number   Version number of the node type record.
--   p_child_node_name                   varchar2 The name of the child node.
--   p_child_value_set                   varchar2 The id of the valueset supplying
--                                                values for the type.
--   p_parent_node_type                  varchar2 The type of the parent node.
--   p_description                       varchar2 Description of the node type.
--
-- Post Success:
--   The node type record and associated lookup value record is updated and the
--   API sets the following out parameters.
--
--   Name                           Type     Description
--   p_object_version_number        number   If p_validate is false, set to
--                                           the new version number of this
--                                           node type.
--                                           If p_validate is true, set to
--                                           null same value passed in.
--
-- Post Failure:
--   The API does not update the node type and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_node_type
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_hier_node_type_id             in     number
  ,p_object_version_number         in out nocopy  number
  ,p_child_node_name               in     varchar2 default hr_api.g_varchar2
  ,p_child_value_set               in     varchar2 default hr_api.g_varchar2
  ,p_parent_node_type              in     varchar2 default hr_api.g_varchar2
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  );

-- ----------------------------------------------------------------------------
-- |----------------------------< delete_node_type >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API deletes a HRMS Calendar specifc node type record as identified by
--   the in parameter p_hier_node_type_id and p_object_version_number.
--   It should not be used to delete other node type hierarchy data as
--   it also attempts to delete the lookup value that is associated with
--   the calendar node type.
--
-- Prerequisites:
--   The node type as identified by the in parameter p_hier_node_type_id and the
--   in parameter p_object_version_number must already exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the node type is deleted.
--   p_hier_node_type_id            Yes  number   Primary key of the node type.
--   p_object_version_number        Yes  number   Current version of the
--                                                node type
--
-- Post Success:
--   The node type is deleted.
--
-- Post Failure:
--   The API does not delete the node type and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_node_type
  (p_validate                      in     boolean  default false
  ,p_hier_node_type_id             in     number
  ,p_object_version_number         in     number
  );
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< get_node_level >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- function to return the level of a node type within a node type hierarchy.
--
-- In Parameters:
--                                  Reqd Type       Description
--   p_hierarchy_type               Yes  varchar2   Hierarchy type code.
--   p_child_node_type              Yes  varchar2   Child node type code.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
function get_node_level (p_hierarchy_type in VARCHAR2
                       ,p_child_node_type IN VARCHAR2) RETURN NUMBER;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< child_exists >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Returns a Y or N code indicating if children exist for the child_node_type
-- within the hierarchy.
--
-- In Parameters:
--                                  Reqd Type       Description
--   p_hierarchy_type               Yes  varchar2   Hierarchy type code.
--   p_child_node_type              Yes  varchar2   Child node type code.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
function child_exists (p_hierarchy_type in VARCHAR2
                      ,p_child_node_type IN VARCHAR2) RETURN VARCHAR2;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< gen_hier_exists >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Returns a Y or N code indicating if the node_type (scope) hierarchy
-- has been used to create a generic hierarchy.
--
-- In Parameters:
--                                  Reqd Type       Description
--   p_hierarchy_type               Yes  varchar2   Hierarchy type code.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
function gen_hier_exists (p_hierarchy_type in VARCHAR2) RETURN VARCHAR2;
--
--
end HR_CALENDAR_NODE_TYPE_API;

 

/
