--------------------------------------------------------
--  DDL for Package PER_APL_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_APL_INS" AUTHID CURRENT_USER as
/* $Header: peaplrhi.pkh 120.1 2005/10/25 00:30:44 risgupta noship $ */
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
--   p_effective_date
--     Mandatory parameter used for calls to the standard lookup value
--     derivation procedures.
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
  p_rec            in out nocopy per_apl_shd.g_rec_type,
  p_effective_date in date,
  p_validate       in boolean default false,
  p_validate_df_flex in boolean default true -- 4689836
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
--   p_effective_date
--     Mandatory parameter used for calls to the standard lookup value
--     derivation procedures.
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
  p_application_id               out nocopy number,
  p_business_group_id            in number,
  p_person_id                    in number,
  p_date_received                in date,
  p_comments                     in varchar2         default null,
  p_current_employer             in varchar2         default null,
  p_projected_hire_date          in date             default null,
  p_successful_flag              in varchar2         default null,
  p_termination_reason           in varchar2         default null,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_appl_attribute_category      in varchar2         default null,
  p_appl_attribute1              in varchar2         default null,
  p_appl_attribute2              in varchar2         default null,
  p_appl_attribute3              in varchar2         default null,
  p_appl_attribute4              in varchar2         default null,
  p_appl_attribute5              in varchar2         default null,
  p_appl_attribute6              in varchar2         default null,
  p_appl_attribute7              in varchar2         default null,
  p_appl_attribute8              in varchar2         default null,
  p_appl_attribute9              in varchar2         default null,
  p_appl_attribute10             in varchar2         default null,
  p_appl_attribute11             in varchar2         default null,
  p_appl_attribute12             in varchar2         default null,
  p_appl_attribute13             in varchar2         default null,
  p_appl_attribute14             in varchar2         default null,
  p_appl_attribute15             in varchar2         default null,
  p_appl_attribute16             in varchar2         default null,
  p_appl_attribute17             in varchar2         default null,
  p_appl_attribute18             in varchar2         default null,
  p_appl_attribute19             in varchar2         default null,
  p_appl_attribute20             in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_effective_date               in date,
  p_validate                     in boolean   default false,
  p_validate_df_flex in boolean default true -- 4689836
  );
--
end per_apl_ins;

 

/
