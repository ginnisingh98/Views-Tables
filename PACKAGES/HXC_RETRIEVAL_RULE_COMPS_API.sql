--------------------------------------------------------
--  DDL for Package HXC_RETRIEVAL_RULE_COMPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RETRIEVAL_RULE_COMPS_API" AUTHID CURRENT_USER as
/* $Header: hxcrtcapi.pkh 120.0 2005/05/29 05:51:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_retrieval_rule_comps >------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- This API creates the Retrieval rule components
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
--                                                component is created.
--                                                Default is FALSE.
--   p_retrieval_rule_comp_id       Yes  number   Primary Key for entity
--   p_retrieval_rule_id            Yes  number   ID of the retrieval rule to
--                                                which the component belongs
--   p_status                       Yes  varchar2 Status to determine the
--                                                retrieval by an application
--   p_time_recipient_id            Yes  number   ID of the Application that
--                                                retrieves the data
--   p_object_version_number        No   number   Object Version Number
--   p_effective_date               No   date     Effective date
--
-- Post Success:
--
-- The OUT PARAMETERS set,after the retrieval rule component has been created
-- successfully,are:
--
--   Name                           Type     Description
--
--   p_retrieval_rule_comp_id       number   Primary key of the new
--                                           retrieval rule comp
--   p_object_version_number        number   Object version number for the
--                                           new retrieval rule component
--
-- Post Failure:
--
-- The retrieval rule comp will not be created and an application error will be
-- raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_retrieval_rule_comps
  (p_validate                      in     boolean  default false
  ,p_retrieval_rule_comp_id        in out nocopy number
  ,p_object_version_number         in out nocopy number
  ,p_retrieval_rule_id             in     number
  ,p_status                        in     varchar2
  ,p_time_recipient_id             in     number
  ,p_effective_date                in     date     default null
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------<update_retrieval_rule_comps>----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API updates an existing Retrieval Rule Component
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
--                                                then a retrieval rulei comp is
--                                                updated. Default is FALSE.
--   p_retrieval_rule_comp_id       Yes  number   Primary Key for entity
--   p_retrieval_rule_id            Yes  number   ID of the retrieval rule
--                                                to which the comp belongs
--   p_status                       Yes  varchar2 Status to determine the
--                                                retrieval by an application
--   p_time_recipient_id            Yes  number   ID of the Application that
--                                                retrieves the data
--   p_object_version_number        No   number   Object Version Number
--   p_effective_date               No   date     Effective date
--
-- Post Success:
--
-- when the retrieval rule comp has been updated successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_object_version_number        Number   Object version number for the
--                                           updated retrieval rule comp
--
-- Post Failure:
--
-- The retrieval rule comp will not be updated and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_retrieval_rule_comps
  (p_validate                      in     boolean  default false
  ,p_retrieval_rule_comp_id        in     number
  ,p_object_version_number         in out nocopy number
  ,p_retrieval_rule_id             in     number
  ,p_status                        in     varchar2
  ,p_time_recipient_id             in     number
  ,p_effective_date                in     date     default null
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_retrieval_rule_comps >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API deletes an existing retrieval rule component
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
--                                                then the retrieval rule comp
--                                                is deleted. Default is FALSE.
--   p_retrieval_rule_comp_id       Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--
-- Post Success:
--
-- when the retrieval rule comp has been deleted successfully the process
-- completes with success.
--
-- Post Failure:
--
-- The retrieval rule comp will not be deleted and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_retrieval_rule_comps
  (p_validate                       in  boolean  default false
  ,p_retrieval_rule_comp_id         in  number
  ,p_object_version_number          in  number
  );
--
--
-- Added by ksethi ver 115.6
-- ----------------------------------------------------------------------------
-- |------------------------< chk_retr_as_unique >-----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_retr_as_unique
(
  p_retrieval_rule_id  in hxc_retrieval_rules.retrieval_rule_id%TYPE
    );
--
--
END hxc_retrieval_rule_comps_api;

 

/
