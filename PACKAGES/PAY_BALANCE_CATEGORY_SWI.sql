--------------------------------------------------------
--  DDL for Package PAY_BALANCE_CATEGORY_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BALANCE_CATEGORY_SWI" AUTHID CURRENT_USER As
/* $Header: pypbcswi.pkh 120.0 2005/05/29 07:20 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< create_balance_category >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_balance_category_api.create_balance_category
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
PROCEDURE create_balance_category
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_category_name                in     varchar2
  ,p_business_group_id            in     number    default null
  ,p_legislation_code             in     varchar2  default null
  ,p_save_run_balance_enabled     in     varchar2  default null
  ,p_user_category_name           in     varchar2  default null
  ,p_pbc_information_category     in     varchar2  default null
  ,p_pbc_information1             in     varchar2  default null
  ,p_pbc_information2             in     varchar2  default null
  ,p_pbc_information3             in     varchar2  default null
  ,p_pbc_information4             in     varchar2  default null
  ,p_pbc_information5             in     varchar2  default null
  ,p_pbc_information6             in     varchar2  default null
  ,p_pbc_information7             in     varchar2  default null
  ,p_pbc_information8             in     varchar2  default null
  ,p_pbc_information9             in     varchar2  default null
  ,p_pbc_information10            in     varchar2  default null
  ,p_pbc_information11            in     varchar2  default null
  ,p_pbc_information12            in     varchar2  default null
  ,p_pbc_information13            in     varchar2  default null
  ,p_pbc_information14            in     varchar2  default null
  ,p_pbc_information15            in     varchar2  default null
  ,p_pbc_information16            in     varchar2  default null
  ,p_pbc_information17            in     varchar2  default null
  ,p_pbc_information18            in     varchar2  default null
  ,p_pbc_information19            in     varchar2  default null
  ,p_pbc_information20            in     varchar2  default null
  ,p_pbc_information21            in     varchar2  default null
  ,p_pbc_information22            in     varchar2  default null
  ,p_pbc_information23            in     varchar2  default null
  ,p_pbc_information24            in     varchar2  default null
  ,p_pbc_information25            in     varchar2  default null
  ,p_pbc_information26            in     varchar2  default null
  ,p_pbc_information27            in     varchar2  default null
  ,p_pbc_information28            in     varchar2  default null
  ,p_pbc_information29            in     varchar2  default null
  ,p_pbc_information30            in     varchar2  default null
  ,p_balance_category_id             out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_balance_category >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_balance_category_api.update_balance_category
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
PROCEDURE update_balance_category
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_balance_category_id          in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_save_run_balance_enabled     in     varchar2  default hr_api.g_varchar2
  ,p_user_category_name           in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information1             in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information2             in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information3             in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information4             in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information5             in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information6             in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information7             in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information8             in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information9             in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information10            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information11            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information12            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information13            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information14            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information15            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information16            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information17            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information18            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information19            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information20            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information21            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information22            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information23            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information24            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information25            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information26            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information27            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information28            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information29            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information30            in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_balance_category >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_balance_category_api.delete_balance_category
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
PROCEDURE delete_balance_category
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_delete_mode        in     varchar2
  ,p_balance_category_id          in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
 end pay_balance_category_swi;

 

/
