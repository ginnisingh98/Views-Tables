--------------------------------------------------------
--  DDL for Package OTA_RESOURCE_BOOKING_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_RESOURCE_BOOKING_SWI" AUTHID CURRENT_USER As
/* $Header: ottrbswi.pkh 120.3 2006/03/06 02:30 rdola noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< create_resource_booking >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_resource_booking_api.create_resource_booking
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
PROCEDURE create_resource_booking
  (p_effective_date               in     date
  ,p_supplied_resource_id         in     number
  ,p_date_booking_placed          in     date
  ,p_status                       in     varchar2
  ,p_event_id                     in     number    default null
  ,p_absolute_price               in     number    default null
  ,p_booking_person_id            in     number    default null
  ,p_comments                     in     varchar2  default null
  ,p_contact_name                 in     varchar2  default null
  ,p_contact_phone_number         in     varchar2  default null
  ,p_delegates_per_unit           in     number    default null
  ,p_quantity                     in     number    default null
  ,p_required_date_from           in     date      default null
  ,p_required_date_to             in     date      default null
  ,p_required_end_time            in     varchar2  default null
  ,p_required_start_time          in     varchar2  default null
  ,p_deliver_to                   in     varchar2  default null
  ,p_primary_venue_flag           in     varchar2  default null
  ,p_role_to_play                 in     varchar2  default null
  ,p_trb_information_category     in     varchar2  default null
  ,p_trb_information1             in     varchar2  default null
  ,p_trb_information2             in     varchar2  default null
  ,p_trb_information3             in     varchar2  default null
  ,p_trb_information4             in     varchar2  default null
  ,p_trb_information5             in     varchar2  default null
  ,p_trb_information6             in     varchar2  default null
  ,p_trb_information7             in     varchar2  default null
  ,p_trb_information8             in     varchar2  default null
  ,p_trb_information9             in     varchar2  default null
  ,p_trb_information10            in     varchar2  default null
  ,p_trb_information11            in     varchar2  default null
  ,p_trb_information12            in     varchar2  default null
  ,p_trb_information13            in     varchar2  default null
  ,p_trb_information14            in     varchar2  default null
  ,p_trb_information15            in     varchar2  default null
  ,p_trb_information16            in     varchar2  default null
  ,p_trb_information17            in     varchar2  default null
  ,p_trb_information18            in     varchar2  default null
  ,p_trb_information19            in     varchar2  default null
  ,p_trb_information20            in     varchar2  default null
  ,p_display_to_learner_flag      in     varchar2  default null
  ,p_book_entire_period_flag    in     varchar2  default null
--  ,p_unbook_request_flag          in     varchar2  default null
  ,p_chat_id                      in number
  ,p_forum_id                     in number
  ,p_validate                     in     number
  ,p_resource_booking_id          in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ,p_finance_header_id            in number           default null
  ,p_currency_code                in varchar2         default null
  ,p_money_amount                 in number           default null
  ,p_finance_line_id              out nocopy number
  ,p_finance_line_ovn             out nocopy NUMBER
  ,p_timezone_code                IN VARCHAR2 DEFAULT NULL
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_resource_booking >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_resource_booking_api.delete_resource_booking
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
PROCEDURE delete_resource_booking
  (p_resource_booking_id          in     number
  ,p_object_version_number        in     number
  ,p_validate                     in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_resource_booking >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_resource_booking_api.update_resource_booking
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
PROCEDURE update_resource_booking
  (p_effective_date               in     date
  ,p_supplied_resource_id         in     number
  ,p_date_booking_placed          in     date
  ,p_status                       in     varchar2
  ,p_event_id                     in     number    default hr_api.g_number
  ,p_absolute_price               in     number    default hr_api.g_number
  ,p_booking_person_id            in     number    default hr_api.g_number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_contact_name                 in     varchar2  default hr_api.g_varchar2
  ,p_contact_phone_number         in     varchar2  default hr_api.g_varchar2
  ,p_delegates_per_unit           in     number    default hr_api.g_number
  ,p_quantity                     in     number    default hr_api.g_number
  ,p_required_date_from           in     date      default hr_api.g_date
  ,p_required_date_to             in     date      default hr_api.g_date
  ,p_required_end_time            in     varchar2  default hr_api.g_varchar2
  ,p_required_start_time          in     varchar2  default hr_api.g_varchar2
  ,p_deliver_to                   in     varchar2  default hr_api.g_varchar2
  ,p_primary_venue_flag           in     varchar2  default hr_api.g_varchar2
  ,p_role_to_play                 in     varchar2  default hr_api.g_varchar2
  ,p_trb_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_trb_information1             in     varchar2  default hr_api.g_varchar2
  ,p_trb_information2             in     varchar2  default hr_api.g_varchar2
  ,p_trb_information3             in     varchar2  default hr_api.g_varchar2
  ,p_trb_information4             in     varchar2  default hr_api.g_varchar2
  ,p_trb_information5             in     varchar2  default hr_api.g_varchar2
  ,p_trb_information6             in     varchar2  default hr_api.g_varchar2
  ,p_trb_information7             in     varchar2  default hr_api.g_varchar2
  ,p_trb_information8             in     varchar2  default hr_api.g_varchar2
  ,p_trb_information9             in     varchar2  default hr_api.g_varchar2
  ,p_trb_information10            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information11            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information12            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information13            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information14            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information15            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information16            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information17            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information18            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information19            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information20            in     varchar2  default hr_api.g_varchar2
  ,p_display_to_learner_flag      in     varchar2  default hr_api.g_varchar2
  ,p_book_entire_period_flag    in     varchar2  default hr_api.g_varchar2
 -- ,p_unbook_request_flag	  in     varchar2  default hr_api.g_varchar2
  ,p_chat_id                      in number
  ,p_forum_id                     in number
  ,p_validate                     in     number
  ,p_resource_booking_id          in     number
  ,p_object_version_number        in   out nocopy number
  ,p_return_status                   out nocopy varchar2
  ,p_finance_header_id            in number           default null
  ,p_currency_code                in varchar2         default null
  ,p_money_amount                 in number           default null
  ,p_finance_line_id              in out nocopy number
  ,p_finance_line_transfer        in varchar2         default null
  ,p_finance_line_ovn             in out nocopy number
  ,p_cancel_finance_line          in varchar2         default null
  ,p_finance_change_flag          in varchar2         default 'N'
  ,p_timezone_code                IN VARCHAR2      DEFAULT hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_trainer_competence >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_resource_booking_api_procedures.check_trainer_competence
--
-- Pre-requisites
--
-- Post Success:
--
-- Post Failure:
--
-- Access Status:
--
-- {End of comments}
-- ----------------------------------------------------------------------------
procedure check_trainer_competence
  (p_event_id                       in              number
  ,p_supplied_resource_id           in              number
  ,p_required_date_from             in              date
  ,p_required_date_to               in              date
  ,p_warning                        out nocopy      varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_double_booking >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_resource_booking_api_procedures.check_double_booking
--
-- Pre-requisites
--
-- Post Success:
--
-- Post Failure:
--
-- Access Status:
--
-- {End of comments}
-- ----------------------------------------------------------------------------
procedure check_double_booking
  (p_supplied_resource_id           in              number
  ,p_required_date_from             in              date
  ,p_required_start_time            in              varchar2
  ,p_required_date_to               in              date
  ,p_required_end_time              in              varchar2
  ,p_resource_booking_id            in              number
  ,p_book_entire_period_flag              in              varchar2
  ,p_warning                        out nocopy      VARCHAR2
  ,p_timezone_code                  IN              VARCHAR2
  );
--
end ota_resource_booking_swi;

 

/
