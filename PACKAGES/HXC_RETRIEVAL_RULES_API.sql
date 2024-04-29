--------------------------------------------------------
--  DDL for Package HXC_RETRIEVAL_RULES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RETRIEVAL_RULES_API" AUTHID CURRENT_USER as
/* $Header: hxcrtrapi.pkh 120.0 2005/05/29 05:52:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_retrieval_rules >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- This API creates the Retrieval Rules
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
--                                                then a new Retrieval rule
--                                                is created.
--                                                Default is FALSE.
--   p_retrieval_rule_id            Yes  number   Primary Key for entity
--   p_retrieval_process_id         Yes  number   ID for the retrieval process
--                                                associated with the rule
--   p_name                         Yes  varchar2 Name of the Retrieval rule
--   p_object_version_number        No   number   Object Version Number
--   p_effective_date               No   date     Effective date
--
-- Post Success:
--
-- The OUT PARAMETERS set,after the retrieval rule has been created
-- successfully,are:
--
--   Name                           Type     Description
--
--   p_retrieval_rule_id            number   Primary key of the new
--                                           retrieval rule
--   p_object_version_number        number   Object version number for the
--                                           new retrieval rule
--
-- Post Failure:
--
-- The retrieval rule will not be created and an application error will be
-- raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_retrieval_rules
  (p_validate                      in     boolean  default false
  ,p_retrieval_rule_id             in out nocopy number
  ,p_object_version_number         in out nocopy number
  ,p_retrieval_process_id          in     number
  ,p_name                          in     varchar2
  ,p_effective_date                in     date     default null
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------<update_retrieval_rules>--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API updates an existing Retrieval Rules
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
--                                                then a retrieval rule is
--                                                updated. Default is FALSE.
--   p_retrieval_rule_id            Yes  number   Primary Key for entity
--   p_retrieval_process_id         Yes  number   ID of the Retrieval process
--                                                associated with the rule
--   p_name                         Yes  varchar2 Retrieval rule name
--   p_object_version_number        No   number   Object Version Number
--   p_effective_date               No   date     Effective date
--
-- Post Success:
--
-- when the retrieval rule has been updated successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_object_version_number        Number   Object version number for the
--                                           updated retrieval rule
--
-- Post Failure:
--
-- The retrieval rule will not be updated and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_retrieval_rules
  (p_validate                      in     boolean  default false
  ,p_retrieval_rule_id             in     number
  ,p_object_version_number         in out nocopy number
  ,p_retrieval_process_id          in     number
  ,p_name                          in     varchar2
  ,p_effective_date                in     date     default null
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_retrieval_rules >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API deletes an existing retrieval rule
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
--                                                then the retrieval rule
--                                                is deleted. Default is FALSE.
--   p_retrieval_rule_id            Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--
-- Post Success:
--
-- when the retrieval rule has been deleted successfully the process
-- completes with success.
--
-- Post Failure:
--
-- The retrieval rule will not be deleted and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_retrieval_rules
  (p_validate                       in  boolean  default false
  ,p_retrieval_rule_id              in  number
  ,p_object_version_number          in  number
  );
--
--
END hxc_retrieval_rules_api;

 

/
