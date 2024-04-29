--------------------------------------------------------
--  DDL for Package HR_NL_ABSENCE_ACTION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NL_ABSENCE_ACTION_SWI" AUTHID CURRENT_USER As
/* $Header: hrnaaswi.pkh 120.0.12000000.1 2007/01/21 17:24:31 appldev ship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< create_absence_action >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_nl_absence_action_api.create_absence_action
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE create_absence_action
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_absence_attendance_id        in     number
  ,p_expected_date                in     date
  ,p_description                  in     varchar2
  ,p_actual_start_date            in     date      default null
  ,p_actual_end_date              in     date      default null
  ,p_holder                       in     varchar2  default null
  ,p_comments                     in     varchar2  default null
  ,p_document_file_name           in     varchar2  default null
  ,p_absence_action_id            out nocopy     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ,p_enabled                      in      varchar2  default null
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_absence_action >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_nl_absence_action_api.delete_absence_action
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_absence_action
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_absence_action_id            in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_absence_action >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_nl_absence_action_api.update_absence_action
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE update_absence_action
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_absence_attendance_id        in     number
  ,p_absence_action_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_expected_date                in     date
  ,p_description                  in     varchar2
  ,p_actual_start_date            in     date      default hr_api.g_date
  ,p_actual_end_date              in     date      default hr_api.g_date
  ,p_holder                       in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_document_file_name           in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  ,p_enabled                      in     varchar2  default hr_Api.g_varchar2
  );
end hr_nl_absence_action_swi;

 

/
