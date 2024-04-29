--------------------------------------------------------
--  DDL for Package OTA_TAV_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TAV_INS" AUTHID CURRENT_USER as
/* $Header: ottav01t.pkh 120.1.12010000.4 2009/10/13 12:08:46 smahanka ship $ */
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
  p_rec        in out nocopy ota_tav_shd.g_rec_type,
  p_validate   in            boolean default false
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
  p_activity_version_id          out nocopy number,
  p_activity_id                  in number,
  p_superseded_by_act_version_id in number           default null,
  p_developer_organization_id    in number,
  p_controlling_person_id        in number           default null,
  p_object_version_number        out nocopy number,
  p_version_name                 in varchar2,
  p_comments                     in varchar2         default null,
  p_description                  in varchar2         default null,
  p_duration                     in number           default null,
  p_duration_units               in varchar2         default null,
  p_end_date                     in date             default null,
  p_intended_audience            in varchar2         default null,
  p_language_id                  in number           default null,
  p_maximum_attendees            in number           default null,
  p_minimum_attendees            in number           default null,
  p_objectives                   in varchar2         default null,
  p_start_date                   in date             default null,
  p_success_criteria             in varchar2         default null,
  p_user_status                  in varchar2         default null,
  p_vendor_id                    in number           default null,
  p_actual_cost                  in number           default null,
  p_budget_cost                  in number           default null,
  p_budget_currency_code         in varchar2         default null,
  p_expenses_allowed             in varchar2         default null,
  p_professional_credit_type     in varchar2         default null,
  p_professional_credits         in number           default null,
  p_maximum_internal_attendees   in number           default null,
  p_tav_information_category     in varchar2         default null,
  p_tav_information1             in varchar2         default null,
  p_tav_information2             in varchar2         default null,
  p_tav_information3             in varchar2         default null,
  p_tav_information4             in varchar2         default null,
  p_tav_information5             in varchar2         default null,
  p_tav_information6             in varchar2         default null,
  p_tav_information7             in varchar2         default null,
  p_tav_information8             in varchar2         default null,
  p_tav_information9             in varchar2         default null,
  p_tav_information10            in varchar2         default null,
  p_tav_information11            in varchar2         default null,
  p_tav_information12            in varchar2         default null,
  p_tav_information13            in varchar2         default null,
  p_tav_information14            in varchar2         default null,
  p_tav_information15            in varchar2         default null,
  p_tav_information16            in varchar2         default null,
  p_tav_information17            in varchar2         default null,
  p_tav_information18            in varchar2         default null,
  p_tav_information19            in varchar2         default null,
  p_tav_information20            in varchar2         default null,
  p_inventory_item_id 		   in number	     default null,
  p_organization_id		   in number    	     default null,
  p_rco_id				   in number	     default null,
  p_version_code           in varchar2        default null,
  p_business_group_id      in number          default null,
  p_validate                     in boolean   default false,
  p_data_source            in varchar2         default null
  ,p_competency_update_level        in     varchar2  default null,
  p_eres_enabled           	   in varchar2 	     default null

  );

procedure set_base_key_value
  (p_activity_version_id  in  number);
--
end ota_tav_ins;

/
