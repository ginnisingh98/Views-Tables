--------------------------------------------------------
--  DDL for Package HXC_TIME_CATEGORY_COMP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIME_CATEGORY_COMP_API" AUTHID CURRENT_USER as
/* $Header: hxctccapi.pkh 120.0 2005/05/29 05:55:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_time_category_comp>-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API creates a Time Category Comp. The user is ablel to specify a name
-- for the component and the application field name the component relates
-- to.
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
--                                                then a new time_category_comp
--                                                is created. Default is FALSE.
--   p_time_category_comp_id        Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--   p_time_category_id             Yes  number   FK to Master hxc_time_categories
--   p_ref_time_category_id         No   number   FK to hxc_time_categories
--   p_component_type_id            No   number   FK to hxc mapping components
--   p_flex_value_set_id            No   number   FK to fnd_flex_Value_sets
--   p_value_id                     No   Varchar  Value for segment identified by
--                                                mapping_component_id
--   p_is_null                      Yes  Varchar  Null Value ID is treated as IS NULL
--   p_equal_to                     Yes  Varchar  Evaluation is equal or not equal to
--   p_type                         Yes  Varchar  Type of the component
--
-- Post Success:
--
-- when the time_category_comp has been created successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_time_category_comp_id        Number   Primary Key for the new rule
--   p_object_version_number        Number   Object version number for the
--                                           new rule
--
-- Post Failure:
--
-- The Time Category Comp will not be inserted and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_time_category_comp
  (p_validate                       in  boolean   default false
  ,p_time_category_comp_id          in  out nocopy number
  ,p_object_version_number          in  out nocopy number
  ,p_time_category_id               in  number
  ,p_ref_time_category_id           in number
  ,p_component_type_id                 number
  ,p_flex_value_set_id            number
  ,p_value_id                     Varchar2
  ,p_is_null                        in varchar2
  ,p_equal_to                       in varchar2
  ,p_type                           in varchar2
  );
    --
-- ----------------------------------------------------------------------------
-- |------------------------<update_time_category_comp>------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API updates an existing Time Category Comp with a given name, approval
-- rule usage covering a particular date range.
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
--                                                then the time_category_comp
--                                                is updated. Default is FALSE.
--   p_time_category_comp_id         Yes  number   Primary Key for entity
--   p_time_category_id             Yes  number   FK to Master hxc_time_categories
--   p_ref_time_category_id         No   number   FK to hxc_time_categories
--   p_component_type_id            No   number   FK to hxc mapping components
--   p_flex_value_set_id            No   number   FK to fnd_flex_Value_sets
--   p_value_id                     No   Varchar  Value for segment identified by
--                                                mapping_component_id
--   p_is_null                      Yes  Varchar  Null Value ID is treated as IS NULL
--   p_equal_to                     Yes  Varchar  Evaluation is equal or not equal to
--   p_type                         Yes  Varchar  Type of the component

-- Post Success:
--
-- when the time_category_comp has been updated successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_object_version_number        Number   Object version number for the
--                                           updated rule
--
-- Post Failure:
--
-- The Time Category Comp will not be updated and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_time_category_comp
  (p_validate                       in  boolean   default false
  ,p_time_category_comp_id           in  number
  ,p_object_version_number          in  out nocopy number
  ,p_time_category_id             number
  ,p_ref_time_category_id         number
  ,p_component_type_id            number
  ,p_flex_value_set_id            number
  ,p_value_id                     Varchar2
  ,p_is_null                        in varchar2
  ,p_equal_to                       in varchar2
  ,p_type                           in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_time_category_comp >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API deletes an existing Time Category Comp
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
--                                                then the time_category_comp
--                                                is deleted. Default is FALSE.
--   p_time_category_comp_id        Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--
-- Post Success:
--
-- when the time_category_comp has been deleted successfully the process
-- completes with success.
--
-- Post Failure:
--
-- The Time Category Comp will not be deleted and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_time_category_comp
  (p_validate                       in  boolean  default false
  ,p_time_category_comp_id          in  number
  ,p_object_version_number          in  number
  );
--
--
END hxc_time_category_comp_api;

 

/
