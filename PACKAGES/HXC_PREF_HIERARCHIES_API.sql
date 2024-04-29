--------------------------------------------------------
--  DDL for Package HXC_PREF_HIERARCHIES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_PREF_HIERARCHIES_API" AUTHID CURRENT_USER as
/* $Header: hxchphapi.pkh 120.0 2005/05/29 05:36:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_node_data >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This enhancement is to allow the use of the API to load seed data easily.
-- This procedure gets the ID of a node in the hierarchy given the full name
-- of the Preference.get_node_data takes the full name of the preference
-- hierarchy node such as A.B.C and returns the id of the node C in A.B.C
-- So now if node D needs to be added as the child of C ,then id of the node
-- C becomes the p_parent_pref_hierarchy_id for node D.
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   preference_full_name
--   p_name
--
-- Post Success:
--   Processing continues if the ID of a preference is determined
--
-- Post Failure:
--   An application error is raised for no_data_found or invalid data
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure get_node_data
  (
   p_preference_full_name     in varchar2
  ,p_name                     in varchar2
  ,p_business_group_id	      in number
  ,p_legislation_code         in varchar2
  ,p_mode                     out nocopy varchar2
  ,p_pref_hierarchy_id        out nocopy number
  ,p_parent_pref_hierarchy_id out nocopy number
  ,p_object_version_number    out nocopy number
   );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_pref_hierarchies >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- This API creates the Preference Hierarchies.
--
-- Prerequisites:
--
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
-- p_validate                       No   boolean  IF TRUE then the database
--                                                remains unchanged.IF FALSE
--                                                then a new Pref Hierarchy is
--                                                created.Default is FALSE.
-- p_pref_hierarchy_id              Yes  number   Primary Key for entity
-- p_type                           No   varchar2 Specifies the position of the
--                                                node in the hierarchy.
-- p_name                           Yes  varchar2 Name of the pref hierarchy
-- p_parent_pref_hierarchy_id       No   number   Reference to another row of
--                                                this table
-- p_edit_allowed                   Yes  boolean  This flag indicates whether
--                                                or not the user can edit the
--                                                instance of the preference
-- p_displayed                      Yes  boolean  This flag indicates whether
--                                                or not the preference instance
--                                                is displayed on the user pref
--                                                screen
-- p_pref_definition_id             No   number   Only populated for leaf nodes
-- p_attribute_category             No   varchar2 Attribute Category for
--                                                attribute columns.Only popula
--                                                ted for leaf nodes.
-- p_attribute1..n                  No   varchar2 Values for preferences.
--                                                Only populated for leaf nodes
-- p_orig_pref_hierarchy_id         No   number   Used for Setup Form.Stores the
--                                                original pref_hierarcy_id
--                                                while pasting nodes along with
--                                                their child nodes
-- p_orig_parent_hierarchy_id       No   number   Used for Setup Form.Stores the
--                                                original parent_pref_hierarcy_
--                                                id while pasting nodes along
--                                                with their child nodes
-- p_object_version_number          No   number   Object Version Number
-- p_effective_date                 No   date     Effective Date
-- p_top_level_parent_id            No   number   pref_hierarchy_Id of the top
--                                                level parent.Populated for leaf
--						  nodes only.
-- p_code                           No   varchar2 Code indicates the code for
--						  the pref_definition_id and
--						  populated for leaf nodes only.
--
-- Post Success:
--
-- The OUT PARAMETERS set,after the pref hierachy has been created successfully,-- are:
--
--   Name                           Type     Description
--
-- p_pref_hierarchy_id              number   Primary key of the new pref
--                                           hierarchy
-- p_object_version_number          number   Object Version Number of the new
--                                           pref hierarchy
--
-- Post Failure:
--
-- The pref hierarchy will not be created and an application error is raised    --
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_pref_hierarchies
  (p_validate                      in     boolean  default false
  ,p_pref_hierarchy_id             in out nocopy number
  ,p_object_version_number         in out nocopy number
  ,p_type                          in     varchar2 default null
  ,p_name                          in     varchar2
  ,p_business_group_id	           in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_parent_pref_hierarchy_id      in     number   default null
  ,p_edit_allowed                  in     varchar2
  ,p_displayed                     in     varchar2
  ,p_pref_definition_id            in     number   default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_orig_pref_hierarchy_id        in     number   default null
  ,p_orig_parent_hierarchy_id      in     number   default null
  ,p_effective_date                in     date     default null
  ,p_top_level_parent_id           in     number   default null --Performance Fix
  ,p_code	                   in     varchar2 default null
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------<update_pref_hierarchies>-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API updates an existing Preference Hierarchy
--
-- Prerequisites:
--
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
-- p_validate                       No   boolean  IF TRUE then the database
--                                                remains unchanged.IF FALSE
--                                                then a new pref hierarchy is
--                                                created.Default is FALSE.
-- p_pref_hierarchy_id              Yes  number   Primary Key for entity
-- p_type                           No   varchar2 Specifies the position of the
--                                                node in the hierarchy.
-- p_name                           Yes  varchar2 Name of the pref hierarchy
-- p_parent_pref_hierarchy_id       No   number   Reference to another row of
--                                                this table
-- p_edit_allowed                   Yes  boolean  This flag indicates whether
--                                                or not the user can edit the
--                                                instance of the preference
-- p_displayed                      Yes  boolean  This flag indicates whether
--                                                or not the preference instance
--                                                is displayed on the user pref
--                                                screen
-- p_pref_definition_id             No   number   Only populated for leaf nodes
-- p_attribute_category             No   varchar2 Attribute Category for
--                                                attribute columns.Only popula
--                                                ted for leaf nodes.
-- p_attribute1..n                  No   varchar2 Values for preferences.
--                                                Only populated for leaf nodes
-- p_orig_pref_hierarchy_id         No   number   Used for Setup Form.Stores the
--                                                original pref_hierarcy_id
--                                                while pasting nodes along with
--                                                their child nodes
-- p_orig_parent_hierarchy_id       No   number   Used for Setup Form.Stores the
--                                                original parent_pref_hierarcy_
--                                                id while pasting nodes along
--                                                with their child nodes
-- p_object_version_number          No   number   Object Version Number
-- p_effective_date                 No   date     Effective Date
-- p_top_level_parent_id            No   number   pref_hierarchy_Id of the top
--                                                level parent.Populated for leaf
--						  nodes only.
-- p_code                           No   varchar2 Code indicates the code for
--						  the pref_definition_id and
--						  populated for leaf nodes only.
-- Post Success:
--
-- when the pref hierarchy has been updated successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_object_version_number        Number   Object version number for the
--                                           updated pref hierarchies
--
-- Post Failure:
--
-- The pref hierarchy will not be updated and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_pref_hierarchies
  (p_validate                      in     boolean  default false
  ,p_pref_hierarchy_id             in     number
  ,p_object_version_number         in out nocopy number
  ,p_type                          in     varchar2 default null
  ,p_name                          in     varchar2
  ,p_business_group_id	           in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_parent_pref_hierarchy_id      in     number   default null
  ,p_edit_allowed                  in     varchar2
  ,p_displayed                     in     varchar2
  ,p_pref_definition_id            in     number   default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_orig_pref_hierarchy_id        in     number   default null
  ,p_orig_parent_hierarchy_id      in     number   default null
  ,p_effective_date                in     date     default null
  ,p_top_level_parent_id           in     number   default null --Performance Fix
  ,p_code	                   in     varchar2 default null
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_pref_hierarchies >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API deletes an existing Preference Hierarchy
--
-- Prerequisites:
--
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     No   boolean  If TRUE then the database
--                                                remains unchanged. If FALSE
--                                                then the pref hierarchy
--                                                is deleted. Default is FALSE.
--   p_pref_hierarchy_id            Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--
-- Post Success:
--
-- when the pref hierarchy has been deleted successfully the process
-- completes with success.
--
-- Post Failure:
--
-- The pref hierrachy will not be deleted and an application error is raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_pref_hierarchies
  (p_validate                       in  boolean  default false
  ,p_pref_hierarchy_id              in  number
  ,p_object_version_number          in  number
  );
--
end hxc_pref_hierarchies_api;

 

/
