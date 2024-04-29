--------------------------------------------------------
--  DDL for Package HXC_APPROVAL_COMPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APPROVAL_COMPS_API" AUTHID CURRENT_USER as
/* $Header: hxchacapi.pkh 120.1 2006/06/08 15:54:21 gsirigin noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_approval_comps >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- This API creates the Approval Components.
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
--   p_approval_comp_id             Yes  number   Primary Key for entity
--   p_approval_mechanism           Yes  varchar2 Approval Mechanism for the
--                                                Style
--   p_approval_style_id            Yes  number   Approval Style ID
--   p_start_date                   Yes  Date     Start Date of the Approval
--                                                Components
--   p_end_date                     Yes  Date     End Date of the  Approval
--                                                Components
--   p_time_recipient_id            No   number   ID of the Application to
--                                                which the approval component
--                                                is applicable
--   p_approval_mechanism_id        No   number   Approval_mechanism_id
--                                                corresponding to the approval
--                                                mechanism
--   p_approval_order               No   number   The Sequence in which the
--                                                Approval Style is applicable
--                                                to the applications
--   p_wf_item_type                 No   varchar2 WF_ITEM_TYPE of the workflow
--   p_wf_name                      No   varchar2 Workflow Name
--
--   p_object_version_number        No   number   Object Version Number
--   p_effective_date               No   date     Effective date
--
-- Post Success:
--
-- The OUT PARAMETERS set,after the approval component has been created
-- successfully,are:
--
--   Name                           Type     Description
--
--   p_approval_comp_id             number   Primary key of the new
--                                           approval component
--   p_object_version_number        number   Object version number for the
--                                           new approval comp
--
-- Post Failure:
--
-- The approval comp will not be created and an application error will be
-- raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_approval_comps
  (p_validate                      in     boolean  default false
  ,p_approval_comp_id              in out nocopy number
  ,p_object_version_number         in out nocopy number
  ,p_approval_mechanism            in     varchar2
  ,p_approval_style_id             in     number
  ,p_time_recipient_id             in     number   default null
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_approval_mechanism_id         in     number   default null
  ,p_approval_order                in     number   default null
  ,p_wf_item_type                  in     varchar2 default null
  ,p_wf_name                       in     varchar2 default null
  ,p_effective_date                in     date     default null
  ,p_time_category_id              in     number   default null
  ,p_parent_comp_id                in     number   default null
  ,p_parent_comp_ovn               in     number   default null
  ,p_run_recipient_extensions      in     varchar2 default null
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------<update_approval_comps> --------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API updates an existing Approval Component of an Approval Style
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
--                                                then a new Approval Comp is
--                                                created. Default is FALSE.
--   p_approval_comp_id             Yes  number   Primary Key for entity
--   p_approval_mechanism           Yes  varchar2 Approval Mechanism for the
--                                                Style
--   p_approval_style_id            Yes  number   Approval Style ID
--   p_start_date                   Yes  Date     Start Date of the Approval
--                                                Components
--   p_end_date                     Yes  Date     End Date of the  Approval
--                                                Components
--   p_time_recipient_id            No   number   ID of the Application to
--                                                which the approval component
--                                                is applicable
--   p_approval_mechanism_id        No   number   Approval_mechanism_id
--                                                corresponding to the approval
--                                                mechanism
--   p_approval_order               No   number   The Sequence in which the
--                                                Approval Style is applicable
--                                                to the applications
--   p_wf_item_type                 No   varchar2 WF_ITEM_TYPE of the workflow
--   p_wf_name                      No   varchar2 Workflow Name
--
--   p_object_version_number        No   number   Object Version Number
--   p_effective_date               No   date     Effective date
--
-- Post Success:
--
-- when the approval style has been updated successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_object_version_number        Number   Object version number for the
--                                           updated approval component
--
-- Post Failure:
--
-- The approval component will not be updated and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_approval_comps
  (p_validate                      in     boolean  default false
  ,p_approval_comp_id              in     number
  ,p_object_version_number         in out nocopy number
  ,p_approval_mechanism            in     varchar2
  ,p_approval_style_id             in     number
  ,p_time_recipient_id             in     number   default null
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_approval_mechanism_id         in     number   default null
  ,p_approval_order                in     number   default null
  ,p_wf_item_type                  in     varchar2 default null
  ,p_wf_name                       in     varchar2 default null
  ,p_effective_date                in     date     default null
  ,p_time_category_id              in     number   default null
  ,p_parent_comp_id                in     number   default null
  ,p_parent_comp_ovn               in     number   default null
  ,p_run_recipient_extensions      in     varchar2 default null
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_approval_comps >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API deletes an existing Approval Component of an Approval Style
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
--                                                then the approval component
--                                                is deleted. Default is FALSE.
--   p_approval_comp_id             Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--
-- Post Success:
--
-- when the approval component has been deleted successfully the process
-- completes with success.
--
-- Post Failure:
--
-- The approval comp will not be deleted and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_approval_comps
  (p_validate                       in  boolean  default false
  ,p_approval_comp_id              in  number
  ,p_object_version_number          in  number
  );
--
--
END hxc_approval_comps_api;

 

/
