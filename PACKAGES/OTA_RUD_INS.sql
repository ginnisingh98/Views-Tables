--------------------------------------------------------
--  DDL for Package OTA_RUD_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_RUD_INS" AUTHID CURRENT_USER as
/* $Header: otrudrhi.pkh 120.0 2005/05/29 07:32:29 appldev noship $ */
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
  (p_resource_usage_id  in  number);
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
  ,p_rec                      in out nocopy ota_rud_shd.g_rec_type
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
  ,p_activity_version_id            in     number   default null
  ,p_required_flag                  in     varchar2
  ,p_start_date                     in     date
  ,p_supplied_resource_id           in     number   default null
  ,p_comments                       in     varchar2 default null
  ,p_end_date                       in     date     default null
  ,p_quantity                       in     number   default null
  ,p_resource_type                  in     varchar2 default null
  ,p_role_to_play                   in     varchar2 default null
  ,p_usage_reason                   in     varchar2 default null
  ,p_rud_information_category       in     varchar2 default null
  ,p_rud_information1               in     varchar2 default null
  ,p_rud_information2               in     varchar2 default null
  ,p_rud_information3               in     varchar2 default null
  ,p_rud_information4               in     varchar2 default null
  ,p_rud_information5               in     varchar2 default null
  ,p_rud_information6               in     varchar2 default null
  ,p_rud_information7               in     varchar2 default null
  ,p_rud_information8               in     varchar2 default null
  ,p_rud_information9               in     varchar2 default null
  ,p_rud_information10              in     varchar2 default null
  ,p_rud_information11              in     varchar2 default null
  ,p_rud_information12              in     varchar2 default null
  ,p_rud_information13              in     varchar2 default null
  ,p_rud_information14              in     varchar2 default null
  ,p_rud_information15              in     varchar2 default null
  ,p_rud_information16              in     varchar2 default null
  ,p_rud_information17              in     varchar2 default null
  ,p_rud_information18              in     varchar2 default null
  ,p_rud_information19              in     varchar2 default null
  ,p_rud_information20              in     varchar2 default null
  ,p_resource_usage_id                 out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_offering_id                    in     number   default null
  );
--
end ota_rud_ins;

 

/
