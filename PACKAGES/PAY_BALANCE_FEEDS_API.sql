--------------------------------------------------------
--  DDL for Package PAY_BALANCE_FEEDS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BALANCE_FEEDS_API" AUTHID CURRENT_USER as
/* $Header: pypbfapi.pkh 120.0.12010000.1 2008/07/27 23:20:58 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_balance_feed >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Creates a balance feed
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   P_VALIDATE                      N   Boolean  If true database remains
--						  unchanged. If false then
--						  balance feed will be
--						  created in the database.
--   P_EFFECTIVE_DATE                Y   Date
--   P_BUSINESS_GROUP_ID	     N   Number
--   P_LEGISLATION_CODE		     N   varchar2
--   P_BALANCE_TYPE_ID		     Y   Number   Balance type identifier
--   P_INPUT_VALUE_ID		     Y   Number   Input value identifier
--   P_SCALE			     Y   Varchar2
--   P_LEGISLATION_SUBGROUP	     N   varchar2
--   P_INITIAL_FEED		     N   BOOLEAN  This parameter is obsolete
--					          and no longer used.
--						  The value will be derived
--                                                from input value.
--
-- Post Success:
-- When the balance feed is created the following out parameters are set
--
--   Name                           Type     Description
--   P_BALANCE_FEED_ID		    NUMBER   If p_validate is false, this
--                                           uniquely identifies the balance
--                                           attribute default created.
--					     If p_validate is set to true,
--                                           this parameter will be null.
--   P_EFFECTIVE_START_DATE         DATE     Effective Start Date
--					     If p_validate is set to true this
--					     will be set to NULL
--   P_EFFECTIVE_END_DATE           DATE     Effective End Date
--					     If p_validate is set to true this
--					     will be set to NULL
--   P_OBJECT_VERSION_NUMBER        NUMBER   Object Version Number
--					     If p_validate is set to true this
--					     will be set to NULL
--   P_EXIST_RUN_RESULT_WARNING	    BOOLEAN  Will be set to TRUE if processed
--					     run results exist
-- Post Failure:
-- Error Messages are raised if any business rule is violated and the balance
-- feed is not created
--
-- Access Status:
-- Public
--
-- {End Of Comments}
--
procedure create_balance_feed
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_balance_type_id		   in     number
  ,p_input_value_id		   in     number
  ,p_scale			   in     varchar2
  ,p_business_group_id             in     number   default null
  ,p_legislation_code		   in     varchar2 default null
  ,p_legislation_subgroup	   in     varchar2 default null
  ,p_initial_feed		   in     boolean  default false
  ,p_balance_feed_id                  out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_object_version_number            out nocopy number
  ,p_exist_run_result_warning         out nocopy boolean
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_balance_feed >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This API is used to update a balance feed as of the effective date
--
-- Prerequisites:
-- A Balance Feed for a balance must be setup.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   P_VALIDATE                      N   Boolean  If true database remains
--						  unchanged. If false then
--						  balance feed will be
--						  updated in the database.
--   P_EFFECTIVE_DATE                Y   Date	  Effective start date for the
--						  balance feed
--   P_DATETRACK_UPDATE_MODE         Y   varchar2 Update Mode
--   P_BALANCE_FEED_ID		     Y   Number   Id of the Balance feed being
--						  updated
--   P_SCALE			     N   Varchar2 Scale value for the feed being
--						  updated
--
-- Post Success:
-- When the balance feed is updated the following out parameters are set
----   Name                           Type     Description
--   P_EFFECTIVE_START_DATE         DATE     Effective Start Date
--					     If p_validate is set to true this
--					     will be set to NULL
--   P_EFFECTIVE_END_DATE           DATE     Effective End Date
--					     If p_validate is set to true this
--					     will be set to NULL
--   P_OBJECT_VERSION_NUMBER        NUMBER   Object Version Number
--					     If p_validate is set to true this
--					     will be set to NULL
--   P_EXIST_RUN_RESULT_WARNING	    BOOLEAN  Will be set to TRUE if processed
--					     run results exist
-- Post Failure:
-- Error Messages are raised if any business rule is violated and the balance
-- feed is not updated.
--
-- Access Status:
-- Public
--
-- {End Of Comments}
--
procedure update_balance_feed
  (p_validate	                   in     boolean default false
  ,p_effective_date		   in     date
  ,p_datetrack_update_mode	   in     varchar2
  ,p_balance_feed_id		   in     number
  ,p_scale			   in     varchar2 default hr_api.g_number
  ,p_object_version_number	   in out nocopy  number
  ,p_effective_start_date	      out nocopy  date
  ,p_effective_end_date		      out nocopy  date
  ,p_exist_run_result_warning	      out nocopy  boolean
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_balance_feed >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This API is used to Delete a balance feed as identified by p_balance_feed_id
-- and p_object_version_number
-- The delete operation depends on the datetrack mode being selected.
--
-- Prerequisites:
-- The balance feed as identified by the in parameter p_balance_feed_id must
-- already exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate  		     Y   boolean  If true, then the database
--                                                remains unchanged. If false
--						  then the balance feed will
--						  be deleted.
--   p_effective_date        	     Y 	 date     Effective start date for the
--						  balance feed
--   p_datetrack_delete_mode         Y   varchar2 Delete mode.
--   p_balance_feed_id               Y   number   The id of the balance feed
--						  being deleted.
--   p_object_version_number         Y   number   The version number of the feed
--						  being deleted.
--
-- Post Success:
-- When the Balance Feed is deleted the following OUT parameters are set.
--
--   Name                           Type     Description
--   P_EFFECTIVE_START_DATE         DATE     Effective Start Date
--					     If p_validate is set to true this
--					     will be set to NULL
--   P_EFFECTIVE_END_DATE           DATE     Effective End Date
--					     If p_validate is set to true this
--					     will be set to NULL
--   P_OBJECT_VERSION_NUMBER        NUMBER   Object Version Number
--					     If p_validate is set to true this
--					     will be set to NULL
--   P_EXIST_RUN_RESULT_WARNING	    BOOLEAN  Will be set to TRUE if processed
--					     run results exist
-- Post Failure:
-- Error Messages are raised if any business rule is violated and the balance
-- feed is not deleted
--
-- Access Status:
-- Public.
--
-- {End Of Comments}
--
procedure delete_balance_feed
  (p_validate                        in     boolean default false
  ,p_effective_date                  in     date
  ,p_datetrack_delete_mode           in     varchar2
  ,p_balance_feed_id                 in     number
  ,p_object_version_number           in out nocopy number
  ,p_effective_start_date               out nocopy date
  ,p_effective_end_date                 out nocopy date
  ,p_exist_run_result_warning	        out nocopy boolean
  );

end PAY_BALANCE_FEEDS_API;

/
