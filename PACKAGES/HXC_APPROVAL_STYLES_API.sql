--------------------------------------------------------
--  DDL for Package HXC_APPROVAL_STYLES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APPROVAL_STYLES_API" AUTHID CURRENT_USER as
/* $Header: hxchasapi.pkh 120.1 2006/06/08 14:47:44 gsirigin noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_approval_styles >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- This API creates the Approval Styles.
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
--                                                then a new Approval Style is
--                                                created. Default is FALSE.
--   p_approval_style_id            Yes  number   Primary Key for entity
--   p_object_version_number        No   number   Object Version Number
--   p_name                         Yes  varchar2 Name for the Approval Style
--   p_description                  No   varchar2 User description of the style
--
-- Post Success:
--
-- The OUT PARAMETERS set,after the approval style has been created
-- successfully,are:
--
--   Name                           Type     Description
--
--   p_approval_style_id            number   Primary key of the new
--                                           approval style
--   p_object_version_number        number   Object version number for the
--                                           new approval style
--
-- Post Failure:
--
-- The approval style will not be created and an application error will be
-- raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_approval_styles
  (p_validate                      in     boolean  default false
  ,p_approval_style_id             in out nocopy number
  ,p_object_version_number         in out nocopy number
  ,p_name                          in     varchar2
  ,p_business_group_id		   in     number   default null
  ,p_legislation_code		   in     varchar2 default null
  ,p_description                   in     varchar2 default null
  ,p_run_recipient_extensions      in     varchar2 default null
  ,p_admin_role                    in     varchar2 default null
  ,p_error_admin_role              in     varchar2 default null
--  ,p_effective_date                in     date     default null
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------<update_approval_styles>--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API updates an existing Approval Style
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
--                                                then the approval style
--                                                is updated. Default is FALSE.
--   p_approval_style_id            Yes  number   Primary Key for entity
--   p_object_version_number        No   number   Object Version Number
--   p_name                         Yes  varchar2 Name for the Approval Style
--   p_description                  No   varchar2 User description of the style
--
-- Post Success:
--
-- when the approval style has been updated successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_object_version_number        Number   Object version number for the
--                                           updated approval style
--
-- Post Failure:
--
-- The approval style will not be updated and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_approval_styles
  (p_validate                      in     boolean  default false
  ,p_approval_style_id             in     number
  ,p_object_version_number         in out nocopy number
  ,p_name                          in     varchar2
  ,p_business_group_id		   in     number   default hr_api.g_number
  ,p_legislation_code		   in     varchar2 default hr_api.g_varchar2
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_run_recipient_extensions      in     varchar2 default hr_api.g_varchar2
  ,p_admin_role                    in     varchar2 default hr_api.g_varchar2
  ,p_error_admin_role              in     varchar2 default hr_api.g_varchar2
--  ,p_effective_date                in     date     default null
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_approval_styles >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API deletes an existing Approval Style
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
--                                                then the approval style
--                                                is deleted. Default is FALSE.
--   p_approval_style_id            Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--
-- Post Success:
--
-- when the approval style has been deleted successfully the process
-- completes with success.
--
-- Post Failure:
--
-- The approval style will not be deleted and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_approval_styles
  (p_validate                       in  boolean  default false
  ,p_approval_style_id              in  number
  ,p_object_version_number          in  number
  );
--
--
END hxc_approval_styles_api;

 

/
