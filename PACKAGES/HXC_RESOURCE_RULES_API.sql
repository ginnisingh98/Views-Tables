--------------------------------------------------------
--  DDL for Package HXC_RESOURCE_RULES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RESOURCE_RULES_API" AUTHID CURRENT_USER as
/* $Header: hxchrrapi.pkh 120.0 2005/05/29 05:38:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_resource_rules >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- This API creates the Resource Rules.
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
--                                                then a new Resource Rule is
--                                                created.Default is FALSE.
-- p_resource_rule_id               Yes  number   Primary Key for entity
-- p_name                           Yes  varchar2 Name of the resource rule
-- p_eligibility_criteria_type      Yes  varchar2 Eligibilty criteria for the
--                                                resource rule
-- p_eligibility_criteria_id        No   varchar2 ID of the eligibility chosen.
--                                                eg. if eligibility_criteria_
--                                                type is PERSON then the elig
--                                                ibility_criteria_id will be
--                                                PERSON_ID.
-- p_pref_hierarchy_id              Yes  number   ID of the preference hierarcy
--                                                involved in the resource rule
-- p_rule_evaluation_order          Yes  number   The precedence of the resource--                                                rule
-- p_resource_type                  Yes  varchar2 The resource type , the rule
--                                                applies to
-- p_start_date                     No   date     Start date for the resource
--                                                rule
-- p_end_date                       No   date     End date for the resource rule-- p_object_version_number          No   number   Object Version Number
-- p_effective_date                 No   date     Effective Date
--
-- Post Success:
--
-- The OUT PARAMETERS set,after the resource rule has been created successfully,-- are:
--
--   Name                           Type     Description
--
-- p_resource_rule_id               number   Primary key of the new resource
--                                           rule
-- p_object_version_number          number   Object Version Number of the new
--                                           resource rule
--
-- Post Failure:
--
-- The resource rule will not be created and an application error will be raised--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_resource_rules
  (p_validate                      in     boolean  default false
  ,p_resource_rule_id              in out nocopy number
  ,p_object_version_number         in out nocopy number
  ,p_name                          in     varchar2
  ,p_business_group_id	           in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_eligibility_criteria_type     in     varchar2
  ,p_eligibility_criteria_id       in     varchar2 default null
  ,p_pref_hierarchy_id             in     number
  ,p_rule_evaluation_order         in     number
  ,p_resource_type                 in     varchar2
  ,p_start_date                    in     date      default null
  ,p_end_date                      in     date      default null
  ,p_effective_date                in     date      default null
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------<update_resource_rules> --------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API updates an existing Resource Rule
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
--                                                then a new Resource Rule is
--                                                created.Default is FALSE.
-- p_resource_rule_id               Yes  number   Primary Key for entity
-- p_name                           Yes  varchar2 Name of the resource rule
-- p_eligibility_criteria_type      Yes  varchar2 Eligibilty criteria for the
--                                                resource rule
-- p_eligibility_criteria_id        No   varchar2 ID of the eligibility chosen.
--                                                eg. if eligibility_criteria_
--                                                type is PERSON then the elig
--                                                ibility_criteria_id will be
--                                                PERSON_ID.
-- p_pref_hierarchy_id              Yes  number   ID of the preference hierarcy
--                                                involved in the resource rule
-- p_rule_evaluation_order          Yes  number   The precedence of the resource
--                                                rule
-- p_resource_type                  Yes  varchar2 The resource type , the rule
--                                                applies to
-- p_start_date                     No   date     Start date for the resource
--                                                rule
-- p_end_date                       No   date     End date for the resource rule
-- p_object_version_number          No   number   Object Version Number
-- p_effective_date                 No   date     Effective Date
--
-- Post Success:
--
-- when the resource rule has been updated successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_object_version_number        Number   Object version number for the
--                                           updated resource rule
--
-- Post Failure:
--
-- The resource rule will not be updated and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_resource_rules
  (p_validate                      in     boolean  default false
  ,p_resource_rule_id              in     number
  ,p_object_version_number         in out nocopy number
  ,p_name                          in     varchar2
  ,p_business_group_id	           in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_eligibility_criteria_type     in     varchar2
  ,p_eligibility_criteria_id       in     varchar2  default null
  ,p_pref_hierarchy_id             in     number
  ,p_rule_evaluation_order         in     number
  ,p_resource_type                 in     varchar2
  ,p_start_date                    in     date      default null
  ,p_end_date                      in     date      default null
  ,p_effective_date                in     date      default null
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_resource_rules >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API deletes an existing Resource Rule
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
--                                                then the resource rule
--                                                is deleted. Default is FALSE.
--   p_resource_rule_id             Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--
-- Post Success:
--
-- when the resource rule has been deleted successfully the process
-- completes with success.
--
-- Post Failure:
--
-- The resource rule will not be deleted and an application error is raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_resource_rules
  (p_validate                       in  boolean  default false
  ,p_resource_rule_id               in  number
  ,p_object_version_number          in  number
  );
--
end hxc_resource_rules_api;

 

/
