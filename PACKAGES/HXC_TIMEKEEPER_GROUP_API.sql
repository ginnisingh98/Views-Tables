--------------------------------------------------------
--  DDL for Package HXC_TIMEKEEPER_GROUP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMEKEEPER_GROUP_API" AUTHID CURRENT_USER as
/* $Header: hxctkgapi.pkh 120.0 2005/05/29 06:01:34 appldev noship $ */

TYPE r_people IS RECORD ( person_id per_people_f.person_id%TYPE
                        , full_name per_people_f.full_name%TYPE
                        , employee_number per_people_f.employee_number%TYPE
			, tc_period_name  VARCHAR2(80)
			, person_type     VARCHAR2(2000) );
TYPE t_people IS TABLE OF r_people INDEX BY BINARY_INTEGER;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_timekeeper_group >---------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--
-- This API creates a timekeeper group with a given name
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
--                                                then a new data_approval_rule
--                                                is created. Default is FALSE.
--   p_tk_group_id                  No   number   Primary Key for timekeeper group group
--   p_object_version_number        No   number   Object Version Number
--   p_tk_Group_name                Yes  varchar2 tk group Name for the timekeeper_group
--   p_tk_resource_id                  Yes  number   Resource id for the person creating the
--                                                timekeeper group
--   p_business_group_id            Yes  number   business group id column
-- Post Success:
--
-- when the timekeeper_group has been created successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_tk_group_id                  Number   Primary Key for the new rule
--   p_object_version_number        Number   Object version number for the
--                                           new tk group
--
-- Post Failure:
--
-- The timekeeper group will not be inserted and an application error raised
--
-- Access Status:
--   Public.
--
--
procedure create_timekeeper_group
  (p_validate                       in  boolean   default false
  ,p_tk_group_id                    in  out nocopy number
  ,p_object_version_number          in  out nocopy number
  ,p_tk_group_name                  in     varchar2
  ,p_tk_resource_id                 in  number
  ,p_business_group_id              in  number
  );
    --
-- ----------------------------------------------------------------------------
-- |-------------------------<update_timekeeper_group>------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--
-- This API updates an existing Timekeeper_Group with a given name
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
--   p_tk_group_id                  Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--   p_tk_group_name                Yes  varchar2 tk group Name for the timekeeper group
--   p_tk_resource_id               Yes  number   resource id for the person
--   p_business_group_id            Yes  number   business group id column
-- Post Success:
--
-- when the timekeeper group has been updated successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_object_version_number        Number   Object version number for the
--                                           updated rule
--
-- Post Failure:
--
-- The timekeeper_group will not be updated and an application error raised
--
-- Access Status:
--   Public.
--
--
procedure update_timekeeper_group
  (p_validate                       in  boolean   default false
  ,p_tk_group_id                    in  number
  ,p_object_version_number          in  out nocopy number
  ,p_tk_group_name                  in     varchar2
  ,p_tk_resource_id                 in  number
  ,p_business_group_id              in  number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_timekeeper_group >-------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--
-- This API deletes an existing Timekeeper_Group
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
--                                                then the timekeeper_group
--                                                is deleted. Default is FALSE.
--   p_tk_group_id                  Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--
-- Post Success:
--
-- when the timekeeper group has been deleted successfully the process
-- completes with success.
--
-- Post Failure:
--
-- The timekeeper_group will not be deleted and an application error raised
--
-- Access Status:
--   Public.
--
--
procedure delete_timekeeper_group
  (p_validate                       in  boolean  default false
  ,p_tk_group_id                    in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_name >---------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure insures a valid timekeeper group name
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   tk_group_name
--   tk_group_id
--   tk_resource_id
--
-- Post Success:
--   Processing continues if the name business rules have not been violated
--
-- Post Failure:
--   An application error is raised if the name is not valid
--
-- ----------------------------------------------------------------------------
Procedure chk_name
  (
   p_tk_group_name   in varchar2
  ,p_tk_group_id     in number
  ,p_tk_resource_id     in number
  ,p_business_group_id in number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_tk_resource_id>---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure insures a valid tk_resource_id
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   tk_resource_id
--
-- Post Success:
--   Processing continues if the name business rules have not been violated
--
-- Post Failure:
--   An application error is raised if the name is not valid
--
-- ----------------------------------------------------------------------------
Procedure chk_tk_resource_id
  (
   p_tk_resource_id     in number
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
--   tk_group_id
--
-- Post Success:
--   Processing continues if the name is not being referenced
--
-- Post Failure:
--   An application error is raised if the rule is being used.
--
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (
   p_tk_group_id in number
  );


-- ----------------------------------------------------------------------------
-- |------------------------< get_employee >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedures returns the person id and full name associated with the
--   FND USER_ID profile and the HXC HXC_TIMEKEEPER_OVERRIDE profile
--   This information is used in the Timekeeper Group form.
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   p_employee_id
--   p_full_name
--   p_employee_number
--   p_override
--
-- Post Success:
--   Processing continues if the profiles are found
--
-- Post Failure:
--   An application error is raised if the rule is being used.

PROCEDURE get_employee ( p_employee_id     IN OUT NOCOPY NUMBER
                       , p_full_name       IN OUT NOCOPY VARCHAR2
                       , p_employee_number IN OUT NOCOPY varchar2
                       , p_override        IN OUT NOCOPY VARCHAR2 );

-- ----------------------------------------------------------------------------
-- |------------------------< get_assignments >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This function returns a table of assignments based on as assignment set
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   p_assignment_set_id
--
-- Post Success:
--   Processing continues if the assignments are found
--
-- Post Failure:
--   Processing continues;

FUNCTION get_people ( p_populate_id NUMBER
	,             p_populate_type VARCHAR2
	,             p_person_type VARCHAR2
	) RETURN t_people;

END hxc_timekeeper_group_api;

 

/
