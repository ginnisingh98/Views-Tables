--------------------------------------------------------
--  DDL for Package PAY_USER_ROW_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_USER_ROW_SWI" AUTHID CURRENT_USER As
/* $Header: pypurswi.pkh 120.0 2005/05/29 08:02 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------------< create_user_row >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_user_row_api.create_user_row
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
PROCEDURE create_user_row
 (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_user_table_id                in     number
  ,p_row_low_range_or_name        in     varchar2
  ,p_display_sequence             in out nocopy number
  ,p_business_group_id            in     number    default null
  ,p_legislation_code             in     varchar2  default null
  ,p_disable_range_overlap_check  in     number    default null
  ,p_disable_units_check          in     number    default null
  ,p_row_high_range               in     varchar2  default null
  ,p_user_row_id                     out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
   ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< update_user_row >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_user_row_api.update_user_row
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
PROCEDURE update_user_row
 (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_user_row_id                  in     number
  ,p_display_sequence             in out nocopy number
  ,p_object_version_number        in out nocopy number
  ,p_row_low_range_or_name        in     varchar2  default hr_api.g_varchar2
  ,p_disable_range_overlap_check  in     number    default null
  ,p_disable_units_check          in     number    default null
  ,p_row_high_range               in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2

  );
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_user_row >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_user_row_api.delete_user_row
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
PROCEDURE delete_user_row
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_user_row_id                  in     number
  ,p_object_version_number        in out nocopy number
  ,p_disable_range_overlap_check  in     number    default null
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2

  );
 end pay_user_row_swi;

 

/
