--------------------------------------------------------
--  DDL for Package PER_CTR_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CTR_INS" AUTHID CURRENT_USER as
/* $Header: pectrrhi.pkh 120.2 2007/02/19 11:58:34 ssutar ship $ */
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
  (p_contact_relationship_id  in  number);
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
--   1) If the p_validate parameter has been set to true then a savepoint is
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
--   6) If the p_validate parameter has been set to true an exception is
--      raised which is handled and processed by performing a rollback to the
--      savepoint which was issued at the beginning of the Ins process.
--
-- Pre Conditions:
--   The main parameters to the this process have to be in the record
--   format.
--
-- In Parameters:
--   p_validate
--     Determines if the process is to be validated. Setting this
--     boolean value to true will invoke the process to be validated. The
--     default is false. The validation is controlled by a savepoint and
--     rollback mechanism. The savepoint is issued at the beginning of the
--     process and is rollbacked at the end of the process
--     when all the processing has been completed. The rollback is controlled
--     by raising and handling the exception hr_api.validate_enabled. We use
--     the exception because, by raising the exception with the business
--     process, we can exit successfully without having any of the 'OUT'
--     parameters being set.
--
-- Post Success:
--   A fully validated row will be inserted into the specified entity
--   without being committed. If the p_validate parameter has been set to true
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
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec             in out nocopy per_ctr_shd.g_rec_type,
  p_effective_date  in     date,
  p_validate        in     boolean default false
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
-- Pre Conditions:
--
-- In Parameters:
--   p_validate
--     Determines if the process is to be validated. Setting this
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
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_contact_relationship_id      out nocopy number,
  p_business_group_id            in number,
  p_person_id                    in number,
  p_contact_person_id            in number,
  p_contact_type                 in varchar2,
  p_comments                     in long             default null,
  p_primary_contact_flag         in varchar2         default 'N',
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_date_start                   in date             default null,
  p_start_life_reason_id         in number           default null,
  p_date_end                     in date             default null,
  p_end_life_reason_id           in number           default null,
  p_rltd_per_rsds_w_dsgntr_flag  in varchar2         default 'N',
  p_personal_flag                in varchar2         default 'N',
  p_sequence_number              in number           default null,
  p_cont_attribute_category      in varchar2         default null,
  p_cont_attribute1              in varchar2         default null,
  p_cont_attribute2              in varchar2         default null,
  p_cont_attribute3              in varchar2         default null,
  p_cont_attribute4              in varchar2         default null,
  p_cont_attribute5              in varchar2         default null,
  p_cont_attribute6              in varchar2         default null,
  p_cont_attribute7              in varchar2         default null,
  p_cont_attribute8              in varchar2         default null,
  p_cont_attribute9              in varchar2         default null,
  p_cont_attribute10             in varchar2         default null,
  p_cont_attribute11             in varchar2         default null,
  p_cont_attribute12             in varchar2         default null,
  p_cont_attribute13             in varchar2         default null,
  p_cont_attribute14             in varchar2         default null,
  p_cont_attribute15             in varchar2         default null,
  p_cont_attribute16             in varchar2         default null,
  p_cont_attribute17             in varchar2         default null,
  p_cont_attribute18             in varchar2         default null,
  p_cont_attribute19             in varchar2         default null,
  p_cont_attribute20             in varchar2         default null,
  p_cont_information_category      in varchar2         default null,
  p_cont_information1              in varchar2         default null,
  p_cont_information2              in varchar2         default null,
  p_cont_information3              in varchar2         default null,
  p_cont_information4              in varchar2         default null,
  p_cont_information5              in varchar2         default null,
  p_cont_information6              in varchar2         default null,
  p_cont_information7              in varchar2         default null,
  p_cont_information8              in varchar2         default null,
  p_cont_information9              in varchar2         default null,
  p_cont_information10             in varchar2         default null,
  p_cont_information11             in varchar2         default null,
  p_cont_information12             in varchar2         default null,
  p_cont_information13             in varchar2         default null,
  p_cont_information14             in varchar2         default null,
  p_cont_information15             in varchar2         default null,
  p_cont_information16             in varchar2         default null,
  p_cont_information17             in varchar2         default null,
  p_cont_information18             in varchar2         default null,
  p_cont_information19             in varchar2         default null,
  p_cont_information20             in varchar2         default null,
  p_third_party_pay_flag         in varchar2         default 'N',
  p_bondholder_flag              in varchar2         default 'N',
  p_dependent_flag               in varchar2         default 'N',
  p_beneficiary_flag             in varchar2         default 'N',
  p_object_version_number        out nocopy number,
  p_effective_date               in date             default null,
  p_validate                     in boolean          default false
  );
--
end per_ctr_ins;

/
