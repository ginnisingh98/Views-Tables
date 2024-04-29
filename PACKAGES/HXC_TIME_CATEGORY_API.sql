--------------------------------------------------------
--  DDL for Package HXC_TIME_CATEGORY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIME_CATEGORY_API" AUTHID CURRENT_USER as
/* $Header: hxchtcapi.pkh 120.0.12010000.5 2009/01/07 12:08:56 asrajago ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_time_category >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API creates a field mapping with a given name
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
--                                                then a new time category
--                                                is created. Default is FALSE.
--   p_time_category_id             No   number   Primary Key for entity
--   p_object_version_number        No   number   Object Version Number
--   p_time_category_name           Yes  varchar2 time category name
--   p_operator                     Yes  varchar2 the operator to act upon the
--                                                TC components
--
-- Post Success:
--
-- when the mapping has been created successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_time_category_id             Number   Primary Key for the time category
--   p_object_version_number        Number   Object version number for the
--                                           new time category
--
-- Post Failure:
--
-- The mapping will not be inserted and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_time_category
  (p_validate                       in  boolean   default false
  ,p_time_category_id               in  out nocopy number
  ,p_object_version_number          in  out nocopy number
  ,p_time_category_name             in     varchar2
  ,p_operator                       in     varchar2
  ,p_description                    in     varchar2
  ,p_display                        in     varchar2
  );
    --
-- ----------------------------------------------------------------------------
-- |--------------------------------<update_time_category>----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API updates an existing Mapping with a given name, approval
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
--                                                then the data_approval_rule
--                                                is updated. Default is FALSE.
--   p_time_category_id             Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--   p_time_category_name           Yes  varchar2 time category name
--   p_operator                     Yes  varchar2 the operator to act upon the
--                                                TC components
--
-- Post Success:
--
-- when the mapping has been updated successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_object_version_number        Number   Object version number for the
--                                           updated rule
--
-- Post Failure:
--
-- The mapping will not be updated and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_time_category
  (p_validate                       in  boolean   default false
  ,p_time_category_id               in  number
  ,p_object_version_number          in  out nocopy number
  ,p_time_category_name             in  varchar2
  ,p_operator                       in     varchar2
  ,p_description                    in     varchar2
  ,p_display                        in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_time_category >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API deletes an existing Mapping
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
--                                                then the mapping
--                                                is deleted. Default is FALSE.
--   p_time_category_id             Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--
-- Post Success:
--
-- when the mapping has been deleted successfully the process
-- completes with success.
--
-- Post Failure:
--
-- The mapping will not be deleted and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_time_category
  (p_validate                       in  boolean  default false
  ,p_time_category_id               in  number
  ,p_time_Category_name             in  varchar2
  ,p_object_version_number          in  number
  );

-- ----------------------------------------------------------------------------
-- |---------------------------< set_dynamic_sql_string >---------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
-- This API populates the dynamic sql sting TIME_SQL on the hxc_time_category
-- table. It must be called whenever a time category is created or its
-- components are updated.
--
-- Prerequisites:
--
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_time_category_id             Yes  number   Primary Key for entity
--
-- Post Success:
--
-- when the TIME_SQL has been set successfully the process
-- completes with success.
--
-- Post Failure:
--
-- The TIME_SQL will not be created and an application error raised
--
-- Access Status:
--   Public.
--

procedure set_dynamic_sql_string ( p_time_category_id NUMBER );


PROCEDURE delete_old_comps;

FUNCTION get_component_type_name(p_component_type_id  IN NUMBER)
RETURN VARCHAR2;


END hxc_time_category_api;

/
