--------------------------------------------------------
--  DDL for Package PER_PER_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PER_UPD" AUTHID CURRENT_USER as
/* $Header: peperrhi.pkh 120.2.12010000.1 2008/07/28 05:14:29 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the update business
--   process for the specified entity. The role of this process is
--   to perform the datetrack update mode, fully validating the row
--   for the HR schema passing back to the calling process, any system
--   generated values (e.g. object version number attribute). This process
--   is the main backbone of the upd business process. The processing of
--   this procedure is as follows:
--   1) Ensure that the datetrack update mode is valid.
--   2) If the p_validate argument has been set to true then a savepoint
--      is issued.
--   3) The row to be updated is then locked and selected into the record
--      structure g_old_rec.
--   4) Because on update arguments which are not part of the update do not
--      have to be defaulted, we need to build up the updated row by
--      converting any system defaulted arguments to their corresponding
--      value.
--   5) The controlling validation process update_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   6) The pre_update business process is then executed which enables any
--      logic to be processed before the update dml process is executed.
--   7) The update_dml process will physical perform the update dml into the
--      specified entity.
--   8) The post_update business process is then executed which enables any
--      logic to be processed after the update dml process.
--   9) If the p_validate argument has been set to true an exception is
--      raised which is handled and processed by performing a rollback to
--      the savepoint which was issued at the beginning of the upd process.
--
-- Pre Conditions:
--   The main arguments to the business process have to be in the record
--   format.
--
-- In Arguments:
--   p_effective_date
--     Specifies the date of the datetrack update operation.
--   p_datetrack_mode
--     Determines the datetrack update mode.
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
--    p_rec
--     Contains the attributes of the person record
--
-- Post Success:
--   The specified row will be fully validated and datetracked updated for
--   the specified entity without being committed for the datetrack mode. If
--   the p_validate argument has been set to true then all the work will be
--   rolled back.
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
--  12) system_person_type changes from 'EMP' to anything other than 'EX_EMP'
--      or from 'EX_EMP' to anything other than 'EMP'
--  13) The value of system_person_type is not consistent with the values of
--      current_employee_flag and current_emp_or_apl_flag
--  14) The value of system_person_type has changed and the
--      datetrack mode is correction, update_override or update_change_insert
--  15) The value of system_person_type has not changed and the
--      datetrack mode is update_override or update_change_insert
--  16) If a sex value does not exist in hr_lookups
--      where lookup_type = 'SEX' then
--  17) If a title value does not exist in hr_lookups
--      where lookup_type = 'TITLE' then
--  18) If a sex value is 'M'
--      and the title value is 'MISS.','MRS.', 'MS.' then
--  19) If a sex value is 'F'
--      and the title value is 'MR.'
--  20) If the related system person type is 'EMP' or 'EX-EMP' then
--      if a sex value is null then
--  21) If a start date is not the same as the effective start date when the
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
Procedure upd
  (
  p_rec			in out nocopy 	per_per_shd.g_rec_type,
  p_effective_date	in 	date,
  p_datetrack_mode	in 	varchar2,
  p_validate		in 	boolean default false,
  p_name_combination_warning     out nocopy boolean,
  p_dob_null_warning             out nocopy boolean,
  p_orig_hire_warning            out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the datetrack update
--   business process for the specified entity and is the outermost layer.
--   The role of this process is to update a fully validated row into the
--   HR schema passing back to the calling process, any system generated
--   values (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_defs procedure.
--   2) After the conversion has taken place, the corresponding record upd
--      interface business process is executed.
--   3) OUT arguments are then set to their corresponding record arguments.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_effective_date
--     Specifies the date of the datetrack update operation.
--   p_datetrack_mode
--     Determines the datetrack update mode.
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     Boolean value to true will invoke the process to be validated.
--     The default is false.
--
-- Post Success:
--   A fully validated row will be updated for the specified entity
--   without being committed (or rollbacked depending on the p_validate
--   status).
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back. Refer to the upd record interface for details of possible
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
Procedure upd
  (
  p_person_id                    in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_person_type_id               in number           default hr_api.g_number,
  p_last_name                    in varchar2         default hr_api.g_varchar2,
  p_start_date                   in date             default hr_api.g_date,
  p_applicant_number             in out nocopy varchar2,
  p_comment_id                   out nocopy number,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_current_applicant_flag       out nocopy varchar2,
  p_current_emp_or_apl_flag      out nocopy varchar2,
  p_current_employee_flag        out nocopy varchar2,
  p_date_employee_data_verified  in date             default hr_api.g_date,
  p_date_of_birth                in date             default hr_api.g_date,
  p_email_address                in varchar2         default hr_api.g_varchar2,
  p_employee_number              in out nocopy varchar2,
  p_expense_check_send_to_addres in varchar2         default hr_api.g_varchar2,
  p_first_name                   in varchar2         default hr_api.g_varchar2,
  p_full_name                    out nocopy varchar2,
  p_known_as                     in varchar2         default hr_api.g_varchar2,
  p_marital_status               in varchar2         default hr_api.g_varchar2,
  p_middle_names                 in varchar2         default hr_api.g_varchar2,
  p_nationality                  in varchar2         default hr_api.g_varchar2,
  p_national_identifier          in varchar2         default hr_api.g_varchar2,
  p_previous_last_name           in varchar2         default hr_api.g_varchar2,
  p_registered_disabled_flag     in varchar2         default hr_api.g_varchar2,
  p_sex                          in varchar2         default hr_api.g_varchar2,
  p_title                        in varchar2         default hr_api.g_varchar2,
  p_vendor_id                    in number           default hr_api.g_number,
  p_work_telephone               in varchar2         default hr_api.g_varchar2,
  p_request_id                   in number           default hr_api.g_number,
  p_program_application_id       in number           default hr_api.g_number,
  p_program_id                   in number           default hr_api.g_number,
  p_program_update_date          in date             default hr_api.g_date,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_attribute21                  in varchar2         default hr_api.g_varchar2,
  p_attribute22                  in varchar2         default hr_api.g_varchar2,
  p_attribute23                  in varchar2         default hr_api.g_varchar2,
  p_attribute24                  in varchar2         default hr_api.g_varchar2,
  p_attribute25                  in varchar2         default hr_api.g_varchar2,
  p_attribute26                  in varchar2         default hr_api.g_varchar2,
  p_attribute27                  in varchar2         default hr_api.g_varchar2,
  p_attribute28                  in varchar2         default hr_api.g_varchar2,
  p_attribute29                  in varchar2         default hr_api.g_varchar2,
  p_attribute30                  in varchar2         default hr_api.g_varchar2,
  p_per_information_category     in varchar2         default hr_api.g_varchar2,
  p_per_information1             in varchar2         default hr_api.g_varchar2,
  p_per_information2             in varchar2         default hr_api.g_varchar2,
  p_per_information3             in varchar2         default hr_api.g_varchar2,
  p_per_information4             in varchar2         default hr_api.g_varchar2,
  p_per_information5             in varchar2         default hr_api.g_varchar2,
  p_per_information6             in varchar2         default hr_api.g_varchar2,
  p_per_information7             in varchar2         default hr_api.g_varchar2,
  p_per_information8             in varchar2         default hr_api.g_varchar2,
  p_per_information9             in varchar2         default hr_api.g_varchar2,
  p_per_information10            in varchar2         default hr_api.g_varchar2,
  p_per_information11            in varchar2         default hr_api.g_varchar2,
  p_per_information12            in varchar2         default hr_api.g_varchar2,
  p_per_information13            in varchar2         default hr_api.g_varchar2,
  p_per_information14            in varchar2         default hr_api.g_varchar2,
  p_per_information15            in varchar2         default hr_api.g_varchar2,
  p_per_information16            in varchar2         default hr_api.g_varchar2,
  p_per_information17            in varchar2         default hr_api.g_varchar2,
  p_per_information18            in varchar2         default hr_api.g_varchar2,
  p_per_information19            in varchar2         default hr_api.g_varchar2,
  p_per_information20            in varchar2         default hr_api.g_varchar2,
  p_suffix                       in varchar2         default hr_api.g_varchar2,
  p_DATE_OF_DEATH                in date             default hr_api.g_date,
  p_BACKGROUND_CHECK_STATUS      in varchar2         default hr_api.g_varchar2,
  p_BACKGROUND_DATE_CHECK        in date             default hr_api.g_date,
  p_BLOOD_TYPE                   in varchar2         default hr_api.g_varchar2,
  p_CORRESPONDENCE_LANGUAGE      in varchar2         default hr_api.g_varchar2,
  p_FAST_PATH_EMPLOYEE           in varchar2         default hr_api.g_varchar2,
  p_FTE_CAPACITY                 in number           default hr_api.g_number,
  p_HOLD_APPLICANT_DATE_UNTIL    in date             default hr_api.g_date,
  p_HONORS                       in varchar2         default hr_api.g_varchar2,
  p_INTERNAL_LOCATION            in varchar2         default hr_api.g_varchar2,
  p_LAST_MEDICAL_TEST_BY         in varchar2         default hr_api.g_varchar2,
  p_LAST_MEDICAL_TEST_DATE       in date             default hr_api.g_date,
  p_MAILSTOP                     in varchar2         default hr_api.g_varchar2,
  p_OFFICE_NUMBER                in varchar2         default hr_api.g_varchar2,
  p_ON_MILITARY_SERVICE          in varchar2         default hr_api.g_varchar2,
  p_ORDER_NAME                   in varchar2         default hr_api.g_varchar2,
  p_PRE_NAME_ADJUNCT             in varchar2         default hr_api.g_varchar2,
  p_PROJECTED_START_DATE         in date             default hr_api.g_date,
  p_REHIRE_AUTHORIZOR            in varchar2         default hr_api.g_varchar2,
  p_REHIRE_RECOMMENDATION        in varchar2         default hr_api.g_varchar2,
  p_RESUME_EXISTS                in varchar2         default hr_api.g_varchar2,
  p_RESUME_LAST_UPDATED          in date             default hr_api.g_date,
  p_SECOND_PASSPORT_EXISTS       in varchar2         default hr_api.g_varchar2,
  p_STUDENT_STATUS               in varchar2         default hr_api.g_varchar2,
  p_WORK_SCHEDULE                in varchar2         default hr_api.g_varchar2,
  p_PER_INFORMATION21            in varchar2         default hr_api.g_varchar2,
  p_PER_INFORMATION22            in varchar2         default hr_api.g_varchar2,
  p_PER_INFORMATION23            in varchar2         default hr_api.g_varchar2,
  p_PER_INFORMATION24            in varchar2         default hr_api.g_varchar2,
  p_PER_INFORMATION25            in varchar2         default hr_api.g_varchar2,
  p_PER_INFORMATION26            in varchar2         default hr_api.g_varchar2,
  p_PER_INFORMATION27            in varchar2         default hr_api.g_varchar2,
  p_PER_INFORMATION28            in varchar2         default hr_api.g_varchar2,
  p_PER_INFORMATION29            in varchar2         default hr_api.g_varchar2,
  p_PER_INFORMATION30            in varchar2         default hr_api.g_varchar2,
  p_REHIRE_REASON                in varchar2         default hr_api.g_varchar2,
  p_benefit_group_id             in number           default hr_api.g_number,
  p_receipt_of_death_cert_date   in date             default hr_api.g_date,
  p_coord_ben_med_pln_no         in varchar2         default hr_api.g_varchar2,
  p_coord_ben_no_cvg_flag        in varchar2         default hr_api.g_varchar2,
  p_coord_ben_med_ext_er         in varchar2         default hr_api.g_varchar2,
  p_coord_ben_med_pl_name        in varchar2         default hr_api.g_varchar2,
  p_coord_ben_med_insr_crr_name  in varchar2         default hr_api.g_varchar2,
  p_coord_ben_med_insr_crr_ident in varchar2         default hr_api.g_varchar2,
  p_coord_ben_med_cvg_strt_dt    in date             default hr_api.g_date,
  p_coord_ben_med_cvg_end_dt     in date             default hr_api.g_date,
  p_uses_tobacco_flag            in varchar2         default hr_api.g_varchar2,
  p_dpdnt_adoption_date          in date             default hr_api.g_date,
  p_dpdnt_vlntry_svce_flag       in varchar2         default hr_api.g_varchar2,
  p_original_date_of_hire        in date             default hr_api.g_date,
  p_town_of_birth                in varchar2         default hr_api.g_varchar2,
  p_region_of_birth              in varchar2         default hr_api.g_varchar2,
  p_country_of_birth             in varchar2         default hr_api.g_varchar2,
  p_global_person_id             in varchar2         default hr_api.g_varchar2,
  p_party_id                     in number           default hr_api.g_number,
  p_npw_number                   in out nocopy varchar2,
  p_current_npw_flag             in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_effective_date		 in date,
  p_datetrack_mode		 in varchar2,
  p_validate			 in boolean          default false,
  p_name_combination_warning     out nocopy boolean,
  p_dob_null_warning             out nocopy boolean,
  p_orig_hire_warning            out nocopy boolean
  );
--
end per_per_upd;

/
