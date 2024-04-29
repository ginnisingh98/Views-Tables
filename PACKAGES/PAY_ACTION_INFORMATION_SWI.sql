--------------------------------------------------------
--  DDL for Package PAY_ACTION_INFORMATION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ACTION_INFORMATION_SWI" AUTHID CURRENT_USER As
/*  $Header: pyaifswi.pkh 120.0.12000000.2 2007/03/30 05:36:26 ttagawa noship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------< create_action_information >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_action_information_api.create_action_information
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
PROCEDURE create_action_information
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_action_context_id            in     number
  ,p_action_context_type          in     varchar2
  ,p_action_information_category  in     varchar2
  ,p_tax_unit_id                  in     number    default null
  ,p_jurisdiction_code            in     varchar2  default null
  ,p_source_id                    in     number    default null
  ,p_source_text                  in     varchar2  default null
  ,p_tax_group                    in     varchar2  default null
  ,p_effective_date               in     date      default null
  ,p_assignment_id                in     number    default null
  ,p_action_information1          in     varchar2  default null
  ,p_action_information2          in     varchar2  default null
  ,p_action_information3          in     varchar2  default null
  ,p_action_information4          in     varchar2  default null
  ,p_action_information5          in     varchar2  default null
  ,p_action_information6          in     varchar2  default null
  ,p_action_information7          in     varchar2  default null
  ,p_action_information8          in     varchar2  default null
  ,p_action_information9          in     varchar2  default null
  ,p_action_information10         in     varchar2  default null
  ,p_action_information11         in     varchar2  default null
  ,p_action_information12         in     varchar2  default null
  ,p_action_information13         in     varchar2  default null
  ,p_action_information14         in     varchar2  default null
  ,p_action_information15         in     varchar2  default null
  ,p_action_information16         in     varchar2  default null
  ,p_action_information17         in     varchar2  default null
  ,p_action_information18         in     varchar2  default null
  ,p_action_information19         in     varchar2  default null
  ,p_action_information20         in     varchar2  default null
  ,p_action_information21         in     varchar2  default null
  ,p_action_information22         in     varchar2  default null
  ,p_action_information23         in     varchar2  default null
  ,p_action_information24         in     varchar2  default null
  ,p_action_information25         in     varchar2  default null
  ,p_action_information26         in     varchar2  default null
  ,p_action_information27         in     varchar2  default null
  ,p_action_information28         in     varchar2  default null
  ,p_action_information29         in     varchar2  default null
  ,p_action_information30         in     varchar2  default null
  ,p_action_information_id        in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_action_information >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_action_information_api.delete_action_information
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
PROCEDURE delete_action_information
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_action_information_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< update_action_information >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_action_information_api.update_action_information
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
PROCEDURE update_action_information
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_action_information_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_action_information1          in     varchar2  default hr_api.g_varchar2
  ,p_action_information2          in     varchar2  default hr_api.g_varchar2
  ,p_action_information3          in     varchar2  default hr_api.g_varchar2
  ,p_action_information4          in     varchar2  default hr_api.g_varchar2
  ,p_action_information5          in     varchar2  default hr_api.g_varchar2
  ,p_action_information6          in     varchar2  default hr_api.g_varchar2
  ,p_action_information7          in     varchar2  default hr_api.g_varchar2
  ,p_action_information8          in     varchar2  default hr_api.g_varchar2
  ,p_action_information9          in     varchar2  default hr_api.g_varchar2
  ,p_action_information10         in     varchar2  default hr_api.g_varchar2
  ,p_action_information11         in     varchar2  default hr_api.g_varchar2
  ,p_action_information12         in     varchar2  default hr_api.g_varchar2
  ,p_action_information13         in     varchar2  default hr_api.g_varchar2
  ,p_action_information14         in     varchar2  default hr_api.g_varchar2
  ,p_action_information15         in     varchar2  default hr_api.g_varchar2
  ,p_action_information16         in     varchar2  default hr_api.g_varchar2
  ,p_action_information17         in     varchar2  default hr_api.g_varchar2
  ,p_action_information18         in     varchar2  default hr_api.g_varchar2
  ,p_action_information19         in     varchar2  default hr_api.g_varchar2
  ,p_action_information20         in     varchar2  default hr_api.g_varchar2
  ,p_action_information21         in     varchar2  default hr_api.g_varchar2
  ,p_action_information22         in     varchar2  default hr_api.g_varchar2
  ,p_action_information23         in     varchar2  default hr_api.g_varchar2
  ,p_action_information24         in     varchar2  default hr_api.g_varchar2
  ,p_action_information25         in     varchar2  default hr_api.g_varchar2
  ,p_action_information26         in     varchar2  default hr_api.g_varchar2
  ,p_action_information27         in     varchar2  default hr_api.g_varchar2
  ,p_action_information28         in     varchar2  default hr_api.g_varchar2
  ,p_action_information29         in     varchar2  default hr_api.g_varchar2
  ,p_action_information30         in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  );
 end pay_action_information_swi;

 

/
