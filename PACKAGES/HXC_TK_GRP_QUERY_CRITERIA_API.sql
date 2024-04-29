--------------------------------------------------------
--  DDL for Package HXC_TK_GRP_QUERY_CRITERIA_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TK_GRP_QUERY_CRITERIA_API" AUTHID CURRENT_USER as
/* $Header: hxctkgqcapi.pkh 120.0 2005/05/29 06:14:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------< create_tk_grp_query_criteria >-----------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--
-- This API creates a tk group query criteria row
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
--                                                then a new tk group query
--                                                is created. Default is FALSE.
--   p_tk_group_query_criteria_id   No   number   Primary Key for tk group query criteria
--   p_tk_group_query_id            Yes  number   Foreign Key for tk group query
--   p_tk_group_id                  Yes  number   Foreign Key for tk group id - used to
--                                                maintain the tk group query entity
--   p_object_version_number        No   number   Object Version Number
--   p_criteria_type                Yes  varchar2 criteria type
--   p_criteria id                  Yes  number   id of the criteria specified by the type
--
-- Post Success:
--
-- when the tk_group_query_criteria has been created successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_tk_group_query_criteria_id   Number   Primary Key for the new tk group query
--   p_object_version_number        Number   Object version number for the
--                                           new tk group
--
-- Post Failure:
--
-- The tk group query criteria will not be inserted and an application error raised
--
-- Access Status:
--   Public.
--
--
procedure create_tk_grp_query_criteria
  (p_validate                       in  boolean   default false
  ,p_tk_group_query_criteria_id     in  out nocopy number
  ,p_tk_group_query_id              in  out nocopy number
  ,p_object_version_number          in  out nocopy number
  ,p_tk_group_id                    in  number
  ,p_criteria_type                  in  varchar2
  ,p_criteria_id                    in  number
  );
    --
-- ----------------------------------------------------------------------------
-- |------------------<update_tk_grp_query_criteria >-------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--
-- This API updates an existing Tk_Group_Query_Criteria
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
--                                                then the tk group query
--                                                is updated. Default is FALSE.
--   p_tk_group_query_criteria_id   Yes  number   Primary Key for tk group query criteria
--   p_tk_group_query_id            Yes  number   Foreign Key for tk group query
--   p_object_version_number        Yes  number   Object Version Number
--   p_criteria_type                Yes  varchar2 criteria type
--   p_criteria id                  Yes  number   id of the criteria specified by the type
--
-- Post Success:
--
-- when the tk group query criteria has been updated successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_object_version_number        Number   Object version number for the
--                                           updated tk group query
--
-- Post Failure:
--
-- The tk_group_query_criteria will not be updated and an application error raised
--
-- Access Status:
--   Public.
--
--
procedure update_tk_grp_query_criteria
  (p_validate                       in  boolean   default false
  ,p_tk_group_query_criteria_id     in  number
  ,p_tk_group_query_id              in  number
  ,p_object_version_number          in  out nocopy number
  ,p_criteria_type                  in  varchar2
  ,p_criteria_id                    in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< delete_tk_grp_query_criteria >-------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--
-- This API deletes an existing Tk_Group_Query_Criteria
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
--                                                then the tk_group_query_criteria
--                                                is deleted. Default is FALSE.
--   p_tk_group_query_criteria_id   Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--
-- Post Success:
--
-- when the tk group query criteria has been deleted successfully the process
-- completes with success.
--
-- Post Failure:
--
-- The tk_group_query_criteria will not be deleted and an application error raised
--
-- Access Status:
--   Public.
--
--
procedure delete_tk_grp_query_criteria
  (p_validate                       in  boolean  default false
  ,p_tk_group_query_criteria_id     in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_criteria_type >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure insures a valid tk group query criteria type
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   criteria_type
--
-- Post Success:
--   Processing continues if the name business tk group querys have not been violated
--
-- Post Failure:
--   An application error is raised if the name is not valid
--
-- ----------------------------------------------------------------------------
Procedure chk_criteria_type
  (
   p_criteria_type in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_criteria_id >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure insures a valid tk group query criteria id
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   criteria_type
--   criteria_id
--
-- Post Success:
--   Processing continues if the name business tk group querys have not been violated
--
-- Post Failure:
--   An application error is raised if the name is not valid
--
-- ----------------------------------------------------------------------------
Procedure chk_criteria_id
  (
   p_criteria_type in varchar2
  ,p_criteria_id   in number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_tk_group_query_id >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure insures a valid timekeeper group query id
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   tk_group_query_id
--
-- Post Success:
--   Processing continues if the name business tk group querys have not been violated
--
-- Post Failure:
--   An application error is raised if the name is not valid
--
-- ----------------------------------------------------------------------------
Procedure chk_tk_group_query_id
  (
   p_tk_group_query_id in number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_delete >-------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure carries out delete time referential integrity checks
--   Currently there are none but include this now for minimum impact
--   in the future.
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   tk_group_query_criteria_id
--
-- Post Success:
--   Processing continues if the name is not being referenced
--
-- Post Failure:
--   An application error is raised if the tk group query is being used.
--
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (
   p_tk_group_query_criteria_id in number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_criteria >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
--   This function retrieves the display values for a particular
--   criteria based on the criteria type
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   criteria_type
--   criteria_id
--
--  Usages:
--          used in the hxc_tk_group_query_criteria_v view
--
-- ----------------------------------------------------------------------------
FUNCTION get_criteria ( p_position number
                      , p_criteria_type varchar2
                      , p_criteria_id   number )
RETURN varchar2;

-- ----------------------------------------------------------------------------
-- |-----------------------< chk_criteria_unique >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure check that the criteria id entered is not duplicated
--   within the group query
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   tk_group_query_criteria_id
--   tk_group_query_id
--   criteria_type
--   criteria_id
--
--  Usages:
--          Used in hxc_tk_grp_query criteria api
--
--
-- ----------------------------------------------------------------------------

PROCEDURE chk_criteria_unique (
                        p_tk_group_query_criteria_id in number
                      , p_tk_group_query_id in number
                      , p_criteria_type varchar2
                      , p_criteria_id   number );


--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_tc_period >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
--   This function retrieves the timecard period based on the resource's pref.
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   resource_id
--
--  Usages:
--          used in the hxc_tk_group_query_criteria_v view
--          HXCTKGRP LOVs
--
-- ----------------------------------------------------------------------------
FUNCTION get_tc_period ( p_resource_id number )
RETURN varchar2 DETERMINISTIC;

--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_audit_enabled >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
--   This function retrieves the audit enabled preference
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   resource_id
--
--  Usages:
--          used in the hxc_tk_group_query_criteria_v view
--
-- ----------------------------------------------------------------------------

FUNCTION  check_audit_enabled ( p_resource_id number )
RETURN VARCHAR2;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< tc_period_ok >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
--   This function returns TRUE if the period type and/or duration in days
--   is the same as the period type and/or duration in days for the resource
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   resource_id
--   period_type
--   dusration_in_days
--
--  Usages:
--          used in the hxc_tk_group_query_criteria_v view
--          HXCTKGRP LOVs and populate procedure
--
-- ----------------------------------------------------------------------------
FUNCTION tc_period_ok ( p_resource_id      number
		,	p_period_type      varchar2
		,	p_duration_in_days number )
RETURN BOOLEAN DETERMINISTIC;


END hxc_tk_grp_query_criteria_api;

 

/
