--------------------------------------------------------
--  DDL for Package HXC_DATA_APP_RULE_USAGES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_DATA_APP_RULE_USAGES_API" AUTHID CURRENT_USER as
/* $Header: hxcdruapi.pkh 120.0 2005/05/29 05:29:17 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_data_app_rule_usages >-----------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- This API creates the Data Approval Rule Usages.
--
-- Prerequisites:
--
-- None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     No   boolean  If TRUE then the database
--                                                remains unchanged. If FALSE
--                                                then a new Approval Comp is
--                                                created. Default is FALSE.
--   p_data_app_rule_usage_id       Yes  number   Primary Key for entity
--   p_approval_style_id            Yes  number   Approval Style ID
--   p_time_entry_rule_id           Yes  number   Time Enty Rule ID
--   p_time_recipient_id            No   number   ID of the Application to
--                                                which the data approval rule
--                                                is applicable to
--   p_object_version_number        No   number   Object Version Number
--   p_effective_date               No   date     Effective date
--
-- Post Success:
--
-- The OUT PARAMETERS set,after the data approval rule usage has been created
-- successfully,are:
--
--   Name                           Type     Description
--
--   p_data_app_rule_usage_id       number   Primary key of the new
--                                           data approval rule usage
--   p_object_version_number        number   Object version number for the
--                                           new data approval rule usage
--
-- Post Failure:
--
-- The data approval rule usage will not be created and an application error
-- will be raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_data_app_rule_usages
  (p_validate                      in     boolean  default false
  ,p_data_app_rule_usage_id        in out nocopy number
  ,p_object_version_number         in out nocopy number
  ,p_approval_style_id             in     number
  ,p_time_entry_rule_id            in     number
  ,p_time_recipient_id             in     number
  ,p_effective_date                in     date     default null
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------<update_data_app_rule_usages> --------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API updates an existing Data Approval Rule Usage row
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
--                                                then a new Rule usage is
--                                                created. Default is FALSE.
--   p_data_app_rule_usage_id       Yes  number   Primary Key for entity
--   p_approval_style_id            Yes  number   Approval Style ID
--   p_time_entry_rule_id           Yes  number   Time Entry Rule ID
--   p_time_recipient_id            No   number   ID of the Application to
--                                                which the data approval rule
--                                                is applicable to
--   p_object_version_number        No   number   Object Version Number
--   p_effective_date               No   date     Effective date
--
-- Post Success:
--
-- when the rule usage has been updated successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_object_version_number        Number   Object version number for the
--                                           updated rule usage
--
-- Post Failure:
--
-- The rule usage will not be updated and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_data_app_rule_usages
  (p_validate                      in     boolean  default false
  ,p_data_app_rule_usage_id        in     number
  ,p_object_version_number         in out nocopy number
  ,p_approval_style_id             in     number
  ,p_time_entry_rule_id            in     number
  ,p_time_recipient_id             in     number
  ,p_effective_date                in     date     default null
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_data_app_rule_usages >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API deletes an existing Rule Usage
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
--                                                then the rule usage
--                                                is deleted. Default is FALSE.
--   p_data_app_rule_usage_id       Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--
-- Post Success:
--
-- when the rule usage has been deleted successfully the process
-- completes with success.
--
-- Post Failure:
--
-- The rule usage will not be deleted and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_data_app_rule_usages
  (p_validate                       in  boolean  default false
  ,p_data_app_rule_usage_id         in  number
  ,p_object_version_number          in  number
  );
--
--
END hxc_data_app_rule_usages_api;

 

/
