--------------------------------------------------------
--  DDL for Package PAY_RUN_TYPE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_RUN_TYPE_SWI" AUTHID CURRENT_USER As
/* $Header: pyprtswi.pkh 120.0 2005/05/29 07:53 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------------< create_run_type >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_run_type_api.create_run_type
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
PROCEDURE create_run_type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_language_code                in     varchar2  default null
  ,p_run_type_name                in     varchar2
  ,p_run_method                   in     varchar2
  ,p_business_group_id            in     number    default null
  ,p_legislation_code             in     varchar2  default null
  ,p_shortname                    in     varchar2  default null
  ,p_srs_flag                     in     varchar2  default null
  ,p_run_information_category     in     varchar2  default null
  ,p_run_information1             in     varchar2  default null
  ,p_run_information2             in     varchar2  default null
  ,p_run_information3             in     varchar2  default null
  ,p_run_information4             in     varchar2  default null
  ,p_run_information5             in     varchar2  default null
  ,p_run_information6             in     varchar2  default null
  ,p_run_information7             in     varchar2  default null
  ,p_run_information8             in     varchar2  default null
  ,p_run_information9             in     varchar2  default null
  ,p_run_information10            in     varchar2  default null
  ,p_run_information11            in     varchar2  default null
  ,p_run_information12            in     varchar2  default null
  ,p_run_information13            in     varchar2  default null
  ,p_run_information14            in     varchar2  default null
  ,p_run_information15            in     varchar2  default null
  ,p_run_information16            in     varchar2  default null
  ,p_run_information17            in     varchar2  default null
  ,p_run_information18            in     varchar2  default null
  ,p_run_information19            in     varchar2  default null
  ,p_run_information20            in     varchar2  default null
  ,p_run_information21            in     varchar2  default null
  ,p_run_information22            in     varchar2  default null
  ,p_run_information23            in     varchar2  default null
  ,p_run_information24            in     varchar2  default null
  ,p_run_information25            in     varchar2  default null
  ,p_run_information26            in     varchar2  default null
  ,p_run_information27            in     varchar2  default null
  ,p_run_information28            in     varchar2  default null
  ,p_run_information29            in     varchar2  default null
  ,p_run_information30            in     varchar2  default null
  ,p_run_type_id                     out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< update_run_type >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_run_type_api.update_run_type
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
PROCEDURE update_run_type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_language_code                in     varchar2  default hr_api.g_varchar2
  ,p_run_type_id                  in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_shortname                    in     varchar2  default hr_api.g_varchar2
  ,p_srs_flag                     in     varchar2  default hr_api.g_varchar2
  ,p_run_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_run_information1             in     varchar2  default hr_api.g_varchar2
  ,p_run_information2             in     varchar2  default hr_api.g_varchar2
  ,p_run_information3             in     varchar2  default hr_api.g_varchar2
  ,p_run_information4             in     varchar2  default hr_api.g_varchar2
  ,p_run_information5             in     varchar2  default hr_api.g_varchar2
  ,p_run_information6             in     varchar2  default hr_api.g_varchar2
  ,p_run_information7             in     varchar2  default hr_api.g_varchar2
  ,p_run_information8             in     varchar2  default hr_api.g_varchar2
  ,p_run_information9             in     varchar2  default hr_api.g_varchar2
  ,p_run_information10            in     varchar2  default hr_api.g_varchar2
  ,p_run_information11            in     varchar2  default hr_api.g_varchar2
  ,p_run_information12            in     varchar2  default hr_api.g_varchar2
  ,p_run_information13            in     varchar2  default hr_api.g_varchar2
  ,p_run_information14            in     varchar2  default hr_api.g_varchar2
  ,p_run_information15            in     varchar2  default hr_api.g_varchar2
  ,p_run_information16            in     varchar2  default hr_api.g_varchar2
  ,p_run_information17            in     varchar2  default hr_api.g_varchar2
  ,p_run_information18            in     varchar2  default hr_api.g_varchar2
  ,p_run_information19            in     varchar2  default hr_api.g_varchar2
  ,p_run_information20            in     varchar2  default hr_api.g_varchar2
  ,p_run_information21            in     varchar2  default hr_api.g_varchar2
  ,p_run_information22            in     varchar2  default hr_api.g_varchar2
  ,p_run_information23            in     varchar2  default hr_api.g_varchar2
  ,p_run_information24            in     varchar2  default hr_api.g_varchar2
  ,p_run_information25            in     varchar2  default hr_api.g_varchar2
  ,p_run_information26            in     varchar2  default hr_api.g_varchar2
  ,p_run_information27            in     varchar2  default hr_api.g_varchar2
  ,p_run_information28            in     varchar2  default hr_api.g_varchar2
  ,p_run_information29            in     varchar2  default hr_api.g_varchar2
  ,p_run_information30            in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_run_type >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_run_type_api.delete_run_type
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
PROCEDURE delete_run_type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_delete_mode        in     varchar2
  ,p_run_type_id                  in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
 end pay_run_type_swi;

 

/
