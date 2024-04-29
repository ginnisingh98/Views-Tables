--------------------------------------------------------
--  DDL for Package OTA_TRB_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TRB_UPD" AUTHID CURRENT_USER as
/* $Header: ottrbrhi.pkh 120.3.12000000.1 2007/01/18 05:24:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< upd >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the update
--   process for the specified entity. The role of this process is
--   to update a fully validated row for the HR schema passing back
--   to the calling process, any system generated values (e.g.
--   object version number attribute). This process is the main
--   backbone of the upd business process. The processing of this
--   procedure is as follows:
--   1) The row to be updated is locked and selected into the record
--      structure g_old_rec.
--   2) Because on update parameters which are not part of the update do not
--      have to be defaulted, we need to build up the updated row by
--      converting any system defaulted parameters to their corresponding
--      value.
--   3) The controlling validation process update_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   4) The pre_update process is then executed which enables any
--      logic to be processed before the update dml process is executed.
--   5) The update_dml process will physical perform the update dml into the
--      specified entity.
--   6) The post_update process is then executed which enables any
--      logic to be processed after the update dml process.
--
-- Prerequisites:
--   The main parameters to the business process have to be in the record
--   format.
--
-- In Parameters:
--
-- Post Success:
--   The specified row will be fully validated and updated for the specified
--   entity without being committed.
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy ota_trb_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the update
--   process for the specified entity and is the outermost layer. The role
--   of this process is to update a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes). The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record upd
--      interface process is executed.
--   3) OUT parameters are then set to their corresponding record attributes.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be updated for the specified entity
--   without being committed.
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_resource_booking_id          in     number
  ,p_object_version_number        in out nocopy number
  ,p_supplied_resource_id         in     number    default hr_api.g_number
  ,p_date_booking_placed          in     date      default hr_api.g_date
  ,p_status                       in     varchar2  default hr_api.g_varchar2
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
--  ,p_unbook_request_flag	  in     varchar2  default hr_api.g_varchar2
  ,p_chat_id                     in     number    default hr_api.g_number
  ,p_forum_id                     in     number    default hr_api.g_number
  ,p_timezone_code                IN VARCHAR2   DEFAULT hr_api.g_varchar2
  );
--
end ota_trb_upd;

 

/
