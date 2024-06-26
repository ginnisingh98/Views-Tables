--------------------------------------------------------
--  DDL for Package OTA_TSR_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TSR_INS" AUTHID CURRENT_USER as
/* $Header: ottsr01t.pkh 120.1 2006/02/13 02:49:09 jbharath noship $ */
--
---- ----------------------------------------------------------------------------
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
  (p_supplied_resource_id  in  number);
--
--

-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the insert business process
--   for the specified entity. The role of this process is to insert a fully
--   validated row, into the HR schema passing back to  the calling process,
--   any system generated values (e.g. primary and object version number
--   attributes). This process is the main backbone of the ins business
--   process. The processing of this procedure is as follows:
--   1) If the p_validate argument has been set to true then a savepoint is
--      issued.
--   2) The controlling validation process insert_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   3) The pre_insert business process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   4) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   5) The post_insert business process is then executed which enables any
--      logic to be processed after the insert dml process.
--   6) If the p_validate argument has been set to true an exception is raised
--      which is handled and processed by performing a rollback to the
--      savepoint which was issued at the beginning of the Ins process.
--
-- Pre Conditions:
--   The main arguments to the business process have to be in the record
--   format.
--
-- In Arguments:
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     boolean value to true will invoke the process to be validated. The
--     default is false. The validation is controlled by a savepoint and
--     rollback mechanism. The savepoint is issued at the beginning of the
--     business process and is rollbacked at the end of the business process
--     when all the processing has been completed. The rollback is controlled
--     by raising and handling the exception hr_api.validate_enabled. We use
--     the exception because, by raising the exception with the business
--     process, we can exit successfully without having any of the 'OUT'
--     arguments being set.
--
-- Post Success:
--   A fully validated row will be inserted into the specified entity
--   without being committed. If the p_validate argument has been set to true
--   then all the work will be rolled back.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out nocopy ota_tsr_shd.g_rec_type,
  p_validate   in     boolean default false
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the insert business
--   process for the specified entity and is the outermost layer. The role
--   of this process is to insert a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record ins
--      interface business process is executed.
--   3) OUT arguments are then set to their corresponding record arguments.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     Boolean value to true will invoke the process to be validated.
--     The default is false.
--
-- Post Success:
--   A fully validated row will be inserted for the specified entity
--   without being committed (or rollbacked depending on the p_validate
--   status).
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_supplied_resource_id         out nocopy number,
  p_vendor_id                    in number,
  p_business_group_id            in number,
  p_resource_definition_id       in number,
  p_consumable_flag              in varchar2,
  p_object_version_number        out nocopy number,
  p_resource_type                in varchar2,
  p_start_date                   in date,
  p_comments                     in varchar2         default null,
  p_cost                         in number           default null,
  p_cost_unit                    in varchar2         default null,
  p_currency_code                in varchar2         default null,
  p_end_date                     in date             default null,
  p_internal_address_line        in varchar2         default null,
  p_lead_time                    in number           default null,
  p_name                         in varchar2         default null,
  p_supplier_reference           in varchar2         default null,
  p_tsr_information_category     in varchar2         default null,
  p_tsr_information1             in varchar2         default null,
  p_tsr_information2             in varchar2         default null,
  p_tsr_information3             in varchar2         default null,
  p_tsr_information4             in varchar2         default null,
  p_tsr_information5             in varchar2         default null,
  p_tsr_information6             in varchar2         default null,
  p_tsr_information7             in varchar2         default null,
  p_tsr_information8             in varchar2         default null,
  p_tsr_information9             in varchar2         default null,
  p_tsr_information10            in varchar2         default null,
  p_tsr_information11            in varchar2         default null,
  p_tsr_information12            in varchar2         default null,
  p_tsr_information13            in varchar2         default null,
  p_tsr_information14            in varchar2         default null,
  p_tsr_information15            in varchar2         default null,
  p_tsr_information16            in varchar2         default null,
  p_tsr_information17            in varchar2         default null,
  p_tsr_information18            in varchar2         default null,
  p_tsr_information19            in varchar2         default null,
  p_tsr_information20            in varchar2         default null,
  p_training_center_id           in number	     default null,
  p_location_id			   in number 	     default null,
  p_trainer_id                   in number	     default null,
  p_special_instruction          in varchar2         default null,
  p_validate                     in boolean   default false
  );
--
end ota_tsr_ins;

 

/
