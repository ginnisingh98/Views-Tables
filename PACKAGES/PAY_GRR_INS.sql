--------------------------------------------------------
--  DDL for Package PAY_GRR_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GRR_INS" AUTHID CURRENT_USER as
/* $Header: pygrrrhi.pkh 115.3 2002/12/10 09:48:11 pkakar ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure calls the dt_insert_dml control logic which handles
--   the actual datetrack dml.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory arguments set (except the
--   object_version_number which is initialised within the dt_insert_dml
--   procedure).
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing contines.
--
-- Post Failure:
--   No specific error handling is required within this procedure.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml
	(p_rec 			 in out nocopy pay_grr_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date);
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
--   2) We must lock parent rows (if any exist).
--   3) The controlling validation process insert_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   4) The pre_insert business process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   5) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   6) The post_insert business process is then executed which enables any
--      logic to be processed after the insert dml process.
--   7) If the p_validate argument has been set to true an exception is raised
--      which is handled and processed by performing a rollback to the
--      savepoint which was issued at the beginning of the Ins process.
--
-- Pre Conditions:
--   The main arguments to the business process have to be in the record
--   format. The following attributes in p_rec are mandatory:
--   business_group_id, grade_or_spinal_point_id, rate_id and rate_type
--
-- In Arguments:
--   p_effective_date
--    Specifies the date of the datetrack insert operation.
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
--   p_rec
--     Contains the attributes of the grade rule record.
--
-- Post Success:
--   A fully validated row will be inserted into the specified entity
--   without being committed. If the p_validate argument has been set to true
--   then all the work will be rolled back.
--   p_rec
--     The primary key and object version number details for the inserted
--     grade rule will be returned in p_rec.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back. A failure will occur if any of the following conditions are
--   found:
--     1) All of the mandatory arguments have not been set.
--     2) The p_rec.business_group_id business group does not exist.
--     3) If the grade rule is defined for a grade, the
--        p_rec.grade_or_spinal_point_id does not exist on per_grades
--        (grade_id) or if the grade rule is defined for a spinal point, the
--        p_rec.grade_or_spinal_point_id does not exist on per_spinal_points
--        (spinal_point_id).
--     4) The combination of p_rec.grade_or_spinal_point_id,
--        p_rec.business_group_id, p_rec.rate_id, p_rec.rate_type already
--        exists on pay_grade_rules_f as of the effective date.
--     5) The p_rec.rate_id does not exist in pay_rates.
--     6) The p_rec.rate_type value not in 'G' or 'SP'.
--     7) The combination of p_rec.rate_id and p_rec.rate_type does not
--        exist in pay_rates.
--     8) The p_rec.maximum value is less than the p_rec.minimum value.
--     9) The p_rec.maximum value is less than the p_rec.minimum value.
--     10)The p_rec.mid_value value is less than the p_rec.minimum value.
--     11)The p_rec.mid_value value is greater than the p_rec.maximum value.
--     12)The p_rec.minimum value is greater than the p_rec.value value.
--     13)The combination of p_rec.sequence, p_rec.business_group_id,
--        p_rec.rate_id and p_rate.rate_type already exists on
--        pay_grade_rules_f as of the effective date.
--     14)If the grade rule is defined for a grade, the p_rec.sequence does
--        not correspond to a grade sequence on per_grades (sequence) or if
--        the grade rule is defined for a spinal_point_sequence, the
--        p_rec.sequence does not correspond to a spinal point sequence
--        on per_spinal_points (sequence).
--     15)The p_rec.value value is greater than the p_rec.maximum value.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec		   in out nocopy pay_grr_shd.g_rec_type,
  p_effective_date in     date,
  p_validate	   in     boolean default false
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
--   Refer to the ins record interface for details.
--
-- In Arguments:
--   p_effective_date
--    Specifies the date of the datetrack insert operation.
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     Boolean value to true will invoke the process to be validated.
--     The default is false.
--
-- Post Success:
--   A fully validated row will be inserted for the specified entity
--   without being committed (or rollbacked depending on the p_validate
--   status).
--   p_grade_rule_id
--     will be set to the primary key value of the inserted grade rule.
--   p_object_version_number
--     will be set to the object version number of the inserted grade rule
--   p_effective_start_date
--     will be set to the effective start date of the inserted grade rule
--   p_effective_end_date
--     will be set to the effective end date of the inserted grade rule
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back. Refer to the ins record interface for details of possible
--   failures.
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
  p_grade_rule_id                out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_business_group_id            in number,
  p_rate_id                      in number,
  p_grade_or_spinal_point_id     in number,
  p_rate_type                    in varchar2,
  p_maximum                      in varchar2         default null,
  p_mid_value                    in varchar2         default null,
  p_minimum                      in varchar2         default null,
  p_sequence                     in number           default null,
  p_value                        in varchar2         default null,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_object_version_number        out nocopy number,
  p_effective_date		 in date,
  p_validate			 in boolean   default false,
  p_currency_code                in varchar2  default null
  );
--
end pay_grr_ins;

 

/
