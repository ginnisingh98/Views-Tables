--------------------------------------------------------
--  DDL for Package PER_PER_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PER_INS" AUTHID CURRENT_USER as
/* $Header: peperrhi.pkh 120.2.12010000.1 2008/07/28 05:14:29 appldev ship $ */
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
  (p_person_id  in  number);
--
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml
	(p_rec 			 in out nocopy per_per_shd.g_rec_type,
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
--   format.
--   The following attributes in p_rec are mandatory:
--   person_id, business_group_id, last_name, person_type_id, start_date,
--   effective_start_date, effective_end_date
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
--
-- Post Success:
--   A fully validated row will be inserted into the specified entity
--   without being committed. If the p_validate argument has been set to true
--   then all the work will be rolled back.
--   The primary key and object version number details for the inserted person
--   record will be returned in p_rec
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--   A failure will occur if any of the following conditions are found:
--   1) Any of the mandatory arguments have not been set
--   2) If date of birth > the effective start date then
--   3) If system person type is 'EMP', 'EX_EMP', 'EMP_APL' or 'EX_EMP_APL' and
--      employee number is null
--   4) If system person type is anything other than 'EMP', 'EX_EMP', 'EMP_APL'
--       or 'EX_EMP_APL' and employee number is not null
--   5) If the employee number is not unique within the business group
--   6) If a marital status value does not exist in hr_lookups
--      where lookup_type = 'MAR_STATUS'
--   7) If the national identifier is not valid
--   8) If a nationality value does not exist in hr_lookups
--      where lookup_type = 'NATIONALITY'
--   9) If per_information_category is 'GB' and
--      the following conditions are true then
--      a) per_information1 value does not exist in hr_lookups
--         where lookup_type = 'ETH_TYPE'
--      b) per_information2 does not exist in hr_lookups
--         where lookup_type = 'YES_NO'
--      c) per_information4 does not exist in hr_lookups
--      d) per_information5 is a greater than 30 characters long or lower case
--      e) per_information3 or per_information6 to 20 values are not null
--  10) person_type_id does not exist in per_person_types for the business
--      group
--  11) system_person_type is anything other than 'EMP' or 'EX_EMP'
--  12) The value of system_person_type is not consistent with the values of
--      current_employee_flag and current_emp_or_apl_flag
--  13) If a sex value does not exist in hr_lookups
--      where lookup_type = 'SEX' then
--  14) If a title value does not exist in hr_lookups
--      where lookup_type = 'TITLE' then
--  15) If a sex value is 'M'
--      and the title value is 'MISS.','MRS.', 'MS.' then
--  16) If a sex value is 'F'
--      and the title value is 'MR.'
--  17) If the related system person type is 'EMP' or 'EX-EMP' then
--      if a sex value is null then
--  18) If a start date is not the same as the effective start date when the
--      system person type is 'EMP' or 'EX-EMP'
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
  p_rec		   in out nocopy per_per_shd.g_rec_type,
  p_effective_date in     date,
  p_validate	   in     boolean default false,
  p_name_combination_warning     out nocopy boolean,
  p_dob_null_warning             out nocopy boolean,
  p_orig_hire_warning            out nocopy boolean
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
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back. Refer to the ins record interface for details of possible
--   failures
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
  p_person_id                    out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_business_group_id            in number,
  p_person_type_id               in number,
  p_last_name                    in varchar2,
  p_start_date                   in date,
  p_applicant_number             in out nocopy varchar2,
  p_comment_id                   out nocopy number,
  p_comments                     in varchar2         default null,
  p_current_applicant_flag       out nocopy varchar2,
  p_current_emp_or_apl_flag      out nocopy varchar2,
  p_current_employee_flag        out nocopy varchar2,
  p_date_employee_data_verified  in date             default null,
  p_date_of_birth                in date             default null,
  p_email_address                in varchar2         default null,
  p_employee_number              in out nocopy varchar2,
  p_expense_check_send_to_addres in varchar2         default null,
  p_first_name                   in varchar2         default null,
  p_full_name                    out nocopy varchar2,
  p_known_as                     in varchar2         default null,
  p_marital_status               in varchar2         default null,
  p_middle_names                 in varchar2         default null,
  p_nationality                  in varchar2         default null,
  p_national_identifier          in varchar2         default null,
  p_previous_last_name           in varchar2         default null,
  p_registered_disabled_flag     in varchar2         default null,
  p_sex                          in varchar2         default null,
  p_title                        in varchar2         default null,
  p_vendor_id                    in number           default null,
  p_work_telephone               in varchar2         default null,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
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
  p_per_information_category     in varchar2         default null,
  p_per_information1             in varchar2         default null,
  p_per_information2             in varchar2         default null,
  p_per_information3             in varchar2         default null,
  p_per_information4             in varchar2         default null,
  p_per_information5             in varchar2         default null,
  p_per_information6             in varchar2         default null,
  p_per_information7             in varchar2         default null,
  p_per_information8             in varchar2         default null,
  p_per_information9             in varchar2         default null,
  p_per_information10            in varchar2         default null,
  p_per_information11            in varchar2         default null,
  p_per_information12            in varchar2         default null,
  p_per_information13            in varchar2         default null,
  p_per_information14            in varchar2         default null,
  p_per_information15            in varchar2         default null,
  p_per_information16            in varchar2         default null,
  p_per_information17            in varchar2         default null,
  p_per_information18            in varchar2         default null,
  p_per_information19            in varchar2         default null,
  p_per_information20            in varchar2         default null,
  p_suffix                       in varchar2         default null,
  p_DATE_OF_DEATH                in date             default null,
  p_BACKGROUND_CHECK_STATUS      in varchar2         default null,
  p_BACKGROUND_DATE_CHECK        in date             default null,
  p_BLOOD_TYPE                   in varchar2         default null,
  p_CORRESPONDENCE_LANGUAGE      in varchar2         default null,
  p_FAST_PATH_EMPLOYEE           in varchar2         default null,
  p_FTE_CAPACITY                 in number           default null,
  p_HOLD_APPLICANT_DATE_UNTIL    in date             default null,
  p_HONORS                       in varchar2         default null,
  p_INTERNAL_LOCATION            in varchar2         default null,
  p_LAST_MEDICAL_TEST_BY         in varchar2         default null,
  p_LAST_MEDICAL_TEST_DATE       in date             default null,
  p_MAILSTOP                     in varchar2         default null,
  p_OFFICE_NUMBER                in varchar2         default null,
  p_ON_MILITARY_SERVICE          in varchar2         default null,
  p_ORDER_NAME                   in varchar2         default null,
  p_PRE_NAME_ADJUNCT             in varchar2         default null,
  p_PROJECTED_START_DATE         in date             default null,
  p_REHIRE_AUTHORIZOR            in varchar2         default null,
  p_REHIRE_RECOMMENDATION        in varchar2         default null,
  p_RESUME_EXISTS                in varchar2         default null,
  p_RESUME_LAST_UPDATED          in date             default null,
  p_SECOND_PASSPORT_EXISTS       in varchar2         default null,
  p_STUDENT_STATUS               in varchar2         default null,
  p_WORK_SCHEDULE                in varchar2         default null,
  p_PER_INFORMATION21            in varchar2         default null,
  p_PER_INFORMATION22            in varchar2         default null,
  p_PER_INFORMATION23            in varchar2         default null,
  p_PER_INFORMATION24            in varchar2         default null,
  p_PER_INFORMATION25            in varchar2         default null,
  p_PER_INFORMATION26            in varchar2         default null,
  p_PER_INFORMATION27            in varchar2         default null,
  p_PER_INFORMATION28            in varchar2         default null,
  p_PER_INFORMATION29            in varchar2         default null,
  p_PER_INFORMATION30            in varchar2         default null,
  p_REHIRE_REASON                in varchar2         default null,
  p_benefit_group_id             in number           default null,
  p_receipt_of_death_cert_date   in date             default null,
  p_coord_ben_med_pln_no         in varchar2         default null,
  p_coord_ben_no_cvg_flag        in varchar2         default 'N',
  p_coord_ben_med_ext_er         in varchar2         default null,
  p_coord_ben_med_pl_name        in varchar2         default null,
  p_coord_ben_med_insr_crr_name  in varchar2         default null,
  p_coord_ben_med_insr_crr_ident in varchar2         default null,
  p_coord_ben_med_cvg_strt_dt    in date             default null,
  p_coord_ben_med_cvg_end_dt     in date             default null,
  p_uses_tobacco_flag            in varchar2         default null,
  p_dpdnt_adoption_date          in date             default null,
  p_dpdnt_vlntry_svce_flag       in varchar2         default 'N',
  p_original_date_of_hire        in date             default null,
  p_town_of_birth                in varchar2         default null,
  p_region_of_birth              in varchar2         default null,
  p_country_of_birth             in varchar2         default null,
  p_global_person_id             in varchar2         default null,
  p_party_id                     in number           default null,
  p_npw_number                   in out nocopy varchar2,
  p_current_npw_flag             in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_effective_date		 in date,
  p_validate			 in boolean  default false,
  p_name_combination_warning     out nocopy boolean,
  p_dob_null_warning             out nocopy boolean,
  p_orig_hire_warning            out nocopy boolean
   ) ;
--
end per_per_ins;

/
