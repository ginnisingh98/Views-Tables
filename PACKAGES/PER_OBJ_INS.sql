--------------------------------------------------------
--  DDL for Package PER_OBJ_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_OBJ_INS" AUTHID CURRENT_USER as
/* $Header: peobjrhi.pkh 120.4.12010000.1 2008/07/28 05:04:18 appldev ship $ */
--
--
--
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
  (p_objective_id  in  number);
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
  p_rec        		in out nocopy per_obj_shd.g_rec_type,
  p_effective_date 	in date,
  p_validate   		in boolean default false,
  p_weighting_over_100_warning	     out nocopy	boolean,
  p_weighting_appraisal_warning     out nocopy	boolean
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
  p_objective_id                 out nocopy number,
  p_name                         in varchar2,
  p_target_date                  in date             default null,
  p_start_date                   in date,
  p_business_group_id            in number,
  p_object_version_number        out nocopy number,
  p_owning_person_id             in number,
  p_achievement_date             in date             default null,
  p_detail                       in varchar2         default null,
  p_comments                     in varchar2         default null,
  p_success_criteria             in varchar2         default null,
  p_appraisal_id                 in number           default null,
  p_attribute_category           in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null,

   p_attribute21                  in varchar2         default null,
   p_attribute22                  in varchar2         default null,
   p_attribute23                  in varchar2         default null,
   p_attribute24                  in varchar2         default null,
   p_attribute25                  in varchar2         default null,
   p_attribute26                  in varchar2         default null,
   p_attribute27                  in varchar2         default null,
   p_attribute28                  in varchar2         default null,
   p_attribute29                  in varchar2         default null,
   p_attribute30                  in varchar2         default null,

   p_scorecard_id                 in number           default null,
   p_copied_from_library_id       in number           default null,
   p_copied_from_objective_id     in number           default null,
   p_aligned_with_objective_id    in number           default null,

   p_next_review_date             in date             default null,
   p_group_code                   in varchar2         default null,
   p_priority_code                in varchar2         default null,
   p_appraise_flag                in varchar2         default null,
   p_verified_flag                in varchar2         default null,

   p_target_value                 in number           default null,
   p_actual_value                 in number           default null,
   p_weighting_percent            in number           default null,
   p_complete_percent             in number           default null,
   p_uom_code                     in varchar2         default null,

   p_measurement_style_code       in varchar2         default null,
   p_measure_name                 in varchar2         default null,
   p_measure_type_code            in varchar2         default null,
   p_measure_comments             in varchar2         default null,
   p_sharing_access_code          in varchar2         default null,

   p_weighting_over_100_warning   out nocopy boolean,
   p_weighting_appraisal_warning  out nocopy boolean,

  p_effective_date		 in date,
  p_validate                     in boolean   default false

  );
--
end per_obj_ins;

/
