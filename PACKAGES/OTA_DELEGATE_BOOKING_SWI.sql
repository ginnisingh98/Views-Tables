--------------------------------------------------------
--  DDL for Package OTA_DELEGATE_BOOKING_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_DELEGATE_BOOKING_SWI" AUTHID CURRENT_USER As
/* $Header: otenrswi.pkh 120.3 2005/08/12 00:58:41 rdola noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< create_delegate_booking >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_tdb_api.create_delegate_booking
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
PROCEDURE create_delegate_booking
  (p_effective_date               in     date
  ,p_booking_id                   in     number
  ,p_booking_status_type_id       in     number
  ,p_delegate_person_id           in     number    default null
  ,p_contact_id                   in     number
  ,p_business_group_id            in     number
  ,p_event_id                     in     number
  ,p_customer_id                  in     number    default null
  ,p_authorizer_person_id         in     number    default null
  ,p_date_booking_placed          in     date
  ,p_corespondent                 in     varchar2  default null
  ,p_internal_booking_flag        in     varchar2
  ,p_number_of_places             in     number
  ,p_object_version_number           out nocopy number
  ,p_administrator                in     number    default null
  ,p_booking_priority             in     varchar2  default null
  ,p_comments                     in     varchar2  default null
  ,p_contact_address_id           in     number    default null
  ,p_delegate_contact_phone       in     varchar2  default null
  ,p_delegate_contact_fax         in     varchar2  default null
  ,p_third_party_customer_id      in     number    default null
  ,p_third_party_contact_id       in     number    default null
  ,p_third_party_address_id       in     number    default null
  ,p_third_party_contact_phone    in     varchar2  default null
  ,p_third_party_contact_fax      in     varchar2  default null
  ,p_date_status_changed          in     date      default null
  ,p_failure_reason               in     varchar2  default null
  ,p_attendance_result            in     varchar2  default null
  ,p_language_id                  in     number    default null
  ,p_source_of_booking            in     varchar2  default null
  ,p_special_booking_instructions in     varchar2  default null
  ,p_successful_attendance_flag   in     varchar2  default null
  ,p_tdb_information_category     in     varchar2  default null
  ,p_tdb_information1             in     varchar2  default null
  ,p_tdb_information2             in     varchar2  default null
  ,p_tdb_information3             in     varchar2  default null
  ,p_tdb_information4             in     varchar2  default null
  ,p_tdb_information5             in     varchar2  default null
  ,p_tdb_information6             in     varchar2  default null
  ,p_tdb_information7             in     varchar2  default null
  ,p_tdb_information8             in     varchar2  default null
  ,p_tdb_information9             in     varchar2  default null
  ,p_tdb_information10            in     varchar2  default null
  ,p_tdb_information11            in     varchar2  default null
  ,p_tdb_information12            in     varchar2  default null
  ,p_tdb_information13            in     varchar2  default null
  ,p_tdb_information14            in     varchar2  default null
  ,p_tdb_information15            in     varchar2  default null
  ,p_tdb_information16            in     varchar2  default null
  ,p_tdb_information17            in     varchar2  default null
  ,p_tdb_information18            in     varchar2  default null
  ,p_tdb_information19            in     varchar2  default null
  ,p_tdb_information20            in     varchar2  default null
  ,p_create_finance_line          in     varchar2  default null
  ,p_finance_header_id            in     number    default null
  ,p_currency_code                in     varchar2  default null
  ,p_standard_amount              in     number    default null
  ,p_unitary_amount               in     number    default null
  ,p_money_amount                 in     number    default null
  ,p_booking_deal_id              in     number    default null
  ,p_booking_deal_type            in     varchar2  default null
  ,p_finance_line_id              in out nocopy number
  ,p_enrollment_type              in     varchar2  default null
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_organization_id              in     number    default null
  ,p_sponsor_person_id            in     number    default null
  ,p_sponsor_assignment_id        in     number    default null
  ,p_person_address_id            in     number    default null
  ,p_delegate_assignment_id       in     number    default null
  ,p_delegate_contact_id          in     number    default null
  ,p_delegate_contact_email       in     varchar2  default null
  ,p_third_party_email            in     varchar2  default null
  ,p_person_address_type          in     varchar2  default null
  ,p_line_id                      in     number    default null
  ,p_org_id                       in     number    default null
  ,p_daemon_flag                  in     varchar2  default null
  ,p_daemon_type                  in     varchar2  default null
  ,p_old_event_id                 in     number    default null
  ,p_quote_line_id                in     number    default null
  ,p_interface_source             in     varchar2  default null
  ,p_total_training_time          in     varchar2  default null
  ,p_content_player_status        in     varchar2  default null
  ,p_score                        in     number    default null
  ,p_completed_content            in     number    default null
  ,p_total_content                in     number    default null
  ,p_return_status                out 	 nocopy    varchar2
  ,p_booking_justification_id 	  in 	 number    default null
  ,p_is_history_flag   		  in 	 varchar2  default 'N'
  ,p_override_prerequisites 	  in 	 varchar2 default 'N'
  ,p_override_learner_access 	  in 	 varchar2 default 'N'
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_delegate_booking >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_tdb_api.update_delegate_booking
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
PROCEDURE update_delegate_booking
  (p_effective_date               in     date
  ,p_booking_id                   in     number
  ,p_booking_status_type_id       in     number    default hr_api.g_number
  ,p_delegate_person_id           in     number    default hr_api.g_number
  ,p_contact_id                   in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_event_id                     in     number    default hr_api.g_number
  ,p_customer_id                  in     number    default hr_api.g_number
  ,p_authorizer_person_id         in     number    default hr_api.g_number
  ,p_date_booking_placed          in     date      default hr_api.g_date
  ,p_corespondent                 in     varchar2  default hr_api.g_varchar2
  ,p_internal_booking_flag        in     varchar2  default hr_api.g_varchar2
  ,p_number_of_places             in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_administrator                in     number    default hr_api.g_number
  ,p_booking_priority             in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_contact_address_id           in     number    default hr_api.g_number
  ,p_delegate_contact_phone       in     varchar2  default hr_api.g_varchar2
  ,p_delegate_contact_fax         in     varchar2  default hr_api.g_varchar2
  ,p_third_party_customer_id      in     number    default hr_api.g_number
  ,p_third_party_contact_id       in     number    default hr_api.g_number
  ,p_third_party_address_id       in     number    default hr_api.g_number
  ,p_third_party_contact_phone    in     varchar2  default hr_api.g_varchar2
  ,p_third_party_contact_fax      in     varchar2  default hr_api.g_varchar2
  ,p_date_status_changed          in     date      default hr_api.g_date
  ,p_status_change_comments       in     varchar2  default hr_api.g_varchar2
  ,p_failure_reason               in     varchar2  default hr_api.g_varchar2
  ,p_attendance_result            in     varchar2  default hr_api.g_varchar2
  ,p_language_id                  in     number    default hr_api.g_number
  ,p_source_of_booking            in     varchar2  default hr_api.g_varchar2
  ,p_special_booking_instructions in     varchar2  default hr_api.g_varchar2
  ,p_successful_attendance_flag   in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information1             in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information2             in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information3             in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information4             in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information5             in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information6             in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information7             in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information8             in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information9             in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information10            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information11            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information12            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information13            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information14            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information15            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information16            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information17            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information18            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information19            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information20            in     varchar2  default hr_api.g_varchar2
  ,p_update_finance_line          in     varchar2  default hr_api.g_varchar2
  ,p_tfl_object_version_number    in out nocopy number
  ,p_finance_header_id            in     number    default hr_api.g_number
  ,p_finance_line_id              in out nocopy number
  ,p_standard_amount              in     number    default hr_api.g_number
  ,p_unitary_amount               in     number    default hr_api.g_number
  ,p_money_amount                 in     number    default hr_api.g_number
  ,p_currency_code                in     varchar2  default hr_api.g_varchar2
  ,p_booking_deal_type            in     varchar2  default hr_api.g_varchar2
  ,p_booking_deal_id              in     number    default hr_api.g_number
  ,p_enrollment_type              in     varchar2  default hr_api.g_varchar2
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_sponsor_person_id            in     number    default hr_api.g_number
  ,p_sponsor_assignment_id        in     number    default hr_api.g_number
  ,p_person_address_id            in     number    default hr_api.g_number
  ,p_delegate_assignment_id       in     number    default hr_api.g_number
  ,p_delegate_contact_id          in     number    default hr_api.g_number
  ,p_delegate_contact_email       in     varchar2  default hr_api.g_varchar2
  ,p_third_party_email            in     varchar2  default hr_api.g_varchar2
  ,p_person_address_type          in     varchar2  default hr_api.g_varchar2
  ,p_line_id                      in     number    default hr_api.g_number
  ,p_org_id                       in     number    default hr_api.g_number
  ,p_daemon_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_daemon_type                  in     varchar2  default hr_api.g_varchar2
  ,p_old_event_id                 in     number    default hr_api.g_number
  ,p_quote_line_id                in     number    default hr_api.g_number
  ,p_interface_source             in     varchar2  default hr_api.g_varchar2
  ,p_total_training_time          in     varchar2  default hr_api.g_varchar2
  ,p_content_player_status        in     varchar2  default hr_api.g_varchar2
  ,p_score                        in     number    default hr_api.g_number
  ,p_completed_content            in     number    default hr_api.g_number
  ,p_total_content                in     number    default hr_api.g_number
  ,p_return_status                out 	 nocopy    varchar2
  ,p_booking_justification_id 	  in 	 number    default hr_api.g_number
  ,p_is_history_flag		  in     varchar2  default hr_api.g_varchar2
  ,p_override_prerequisites 	  in 	 varchar2 default 'N'
  ,p_override_learner_access 	  in 	 varchar2 default 'N'
  );

-- ----------------------------------------------------------------------------
-- |------------------------< delete_delegate_booking >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_tdb_api.delete_delegate_booking
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
PROCEDURE delete_delegate_booking
  (p_booking_id                   in     number
  ,p_object_version_number        in     number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  );

end ota_delegate_booking_swi;

 

/
