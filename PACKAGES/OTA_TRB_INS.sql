--------------------------------------------------------
--  DDL for Package OTA_TRB_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TRB_INS" AUTHID CURRENT_USER as
/* $Header: ottrbrhi.pkh 120.3.12000000.1 2007/01/18 05:24:38 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
-- Description:
--   This procedure is called to register the next ID value from the database
--   sequence.
--
-- Prerequisites:
--
-- In Parameters:
--   Primary Key
--
-- Post Success:
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_resource_booking_id  in  number);
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the insert process
--   for the specified entity. The role of this process is to insert a fully
--   validated row, into the HR schema passing back to  the calling process,
--   any system generated values (e.g. primary and object version number
--   attributes). This process is the main backbone of the ins
--   process. The processing of this procedure is as follows:
--   1) The controlling validation process insert_validate is executed
--      which will execute all private and public validation business rule
--      processes.
--   2) The pre_insert business process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   3) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   4) The post_insert business process is then executed which enables any
--      logic to be processed after the insert dml process.
--
-- Prerequisites:
--   The main parameters to the this process have to be in the record
--   format.
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be inserted into the specified entity
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
Procedure ins
  (p_effective_date               in date
  ,p_rec                      in out nocopy ota_trb_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the insert
--   process for the specified entity and is the outermost layer. The role
--   of this process is to insert a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record ins
--      interface process is executed.
--   3) OUT parameters are then set to their corresponding record attributes.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be inserted for the specified entity
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
Procedure ins
  (p_effective_date               in     date
  ,p_supplied_resource_id           in     number
  ,p_date_booking_placed            in     date
  ,p_status                         in     varchar2
  ,p_event_id                       in     number   default null
  ,p_absolute_price                 in     number   default null
  ,p_booking_person_id              in     number   default null
  ,p_comments                       in     varchar2 default null
  ,p_contact_name                   in     varchar2 default null
  ,p_contact_phone_number           in     varchar2 default null
  ,p_delegates_per_unit             in     number   default null
  ,p_quantity                       in     number   default null
  ,p_required_date_from             in     date     default null
  ,p_required_date_to               in     date     default null
  ,p_required_end_time              in     varchar2 default null
  ,p_required_start_time            in     varchar2 default null
  ,p_deliver_to                     in     varchar2 default null
  ,p_primary_venue_flag             in     varchar2 default null
  ,p_role_to_play                   in     varchar2 default null
  ,p_trb_information_category       in     varchar2 default null
  ,p_trb_information1               in     varchar2 default null
  ,p_trb_information2               in     varchar2 default null
  ,p_trb_information3               in     varchar2 default null
  ,p_trb_information4               in     varchar2 default null
  ,p_trb_information5               in     varchar2 default null
  ,p_trb_information6               in     varchar2 default null
  ,p_trb_information7               in     varchar2 default null
  ,p_trb_information8               in     varchar2 default null
  ,p_trb_information9               in     varchar2 default null
  ,p_trb_information10              in     varchar2 default null
  ,p_trb_information11              in     varchar2 default null
  ,p_trb_information12              in     varchar2 default null
  ,p_trb_information13              in     varchar2 default null
  ,p_trb_information14              in     varchar2 default null
  ,p_trb_information15              in     varchar2 default null
  ,p_trb_information16              in     varchar2 default null
  ,p_trb_information17              in     varchar2 default null
  ,p_trb_information18              in     varchar2 default null
  ,p_trb_information19              in     varchar2 default null
  ,p_trb_information20              in     varchar2 default null
  ,p_display_to_learner_flag      in     varchar2  default null
  ,p_book_entire_period_flag    in     varchar2  default null
--  ,p_unbook_request_flag    in     varchar2  default null
  ,p_chat_id                        in     number   default null
  ,p_forum_id                       in     number   default null
  ,p_resource_booking_id               out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_timezone_code                   IN VARCHAR2 DEFAULT NULL
  );
--
end ota_trb_ins;

 

/
