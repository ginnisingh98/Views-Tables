--------------------------------------------------------
--  DDL for Package PER_PER_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PER_SHD" AUTHID CURRENT_USER as
/* $Header: peperrhi.pkh 120.2.12010000.1 2008/07/28 05:14:29 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (
  person_id                         number(10),
  effective_start_date              date,
  effective_end_date                date,
  business_group_id                 number(15),
  person_type_id                    number(15),
  last_name                         varchar2(150),
  start_date                        date,
  applicant_number                  varchar2(30),
  comment_id                        number(15),
  comments                          long,
  current_applicant_flag            varchar2(30),
  current_emp_or_apl_flag           varchar2(30),
  current_employee_flag             varchar2(30),
  date_employee_data_verified       date,
  date_of_birth                     date,
  email_address                     varchar2(240),
  employee_number                   varchar2(30),
  expense_check_send_to_address     varchar2(30),
  first_name                        varchar2(150),
  full_name                         varchar2(240),
  known_as                          varchar2(80),
  marital_status                    varchar2(30),
  middle_names                      varchar2(60),
  nationality                       varchar2(30),
  national_identifier               varchar2(30),
  previous_last_name                varchar2(150),
  registered_disabled_flag          varchar2(30),
  sex                               varchar2(30),
  title                             varchar2(30),
  vendor_id                         number(15),
  work_telephone                    varchar2(60),
  request_id                        number(15),
  program_application_id            number(15),
  program_id                        number(15),
  program_update_date               date,
  attribute_category                varchar2(30),
  attribute1                        varchar2(150),
  attribute2                        varchar2(150),
  attribute3                        varchar2(150),
  attribute4                        varchar2(150),
  attribute5                        varchar2(150),
  attribute6                        varchar2(150),
  attribute7                        varchar2(150),
  attribute8                        varchar2(150),
  attribute9                        varchar2(150),
  attribute10                       varchar2(150),
  attribute11                       varchar2(150),
  attribute12                       varchar2(150),
  attribute13                       varchar2(150),
  attribute14                       varchar2(150),
  attribute15                       varchar2(150),
  attribute16                       varchar2(150),
  attribute17                       varchar2(150),
  attribute18                       varchar2(150),
  attribute19                       varchar2(150),
  attribute20                       varchar2(150),
  attribute21                       varchar2(150),
  attribute22                       varchar2(150),
  attribute23                       varchar2(150),
  attribute24                       varchar2(150),
  attribute25                       varchar2(150),
  attribute26                       varchar2(150),
  attribute27                       varchar2(150),
  attribute28                       varchar2(150),
  attribute29                       varchar2(150),
  attribute30                       varchar2(150),
  per_information_category          varchar2(30),
  per_information1                  varchar2(150),
  per_information2                  varchar2(150),
  per_information3                  varchar2(150),
  per_information4                  varchar2(150),
  per_information5                  varchar2(150),
  per_information6                  varchar2(150),
  per_information7                  varchar2(150),
  per_information8                  varchar2(150),
  per_information9                  varchar2(150),
  per_information10                 varchar2(150),
  per_information11                 varchar2(150),
  per_information12                 varchar2(150),
  per_information13                 varchar2(150),
  per_information14                 varchar2(150),
  per_information15                 varchar2(150),
  per_information16                 varchar2(150),
  per_information17                 varchar2(150),
  per_information18                 varchar2(150),
  per_information19                 varchar2(150),
  per_information20                 varchar2(150),
  object_version_number             number(9),
  suffix                            varchar2(30),
  DATE_OF_DEATH                     DATE,
  BACKGROUND_CHECK_STATUS           VARCHAR2(30),
  BACKGROUND_DATE_CHECK             DATE,
  BLOOD_TYPE                        VARCHAR2(30),
  CORRESPONDENCE_LANGUAGE           VARCHAR2(30),
  FAST_PATH_EMPLOYEE                VARCHAR2(30),
  FTE_CAPACITY                      NUMBER,
  HOLD_APPLICANT_DATE_UNTIL         DATE,
  HONORS                            VARCHAR2(45),
  INTERNAL_LOCATION                 VARCHAR2(45),
  LAST_MEDICAL_TEST_BY              VARCHAR2(60),
  LAST_MEDICAL_TEST_DATE            DATE,
  MAILSTOP                          VARCHAR2(45),
  OFFICE_NUMBER                     VARCHAR2(45),
  ON_MILITARY_SERVICE               VARCHAR2(30),
  ORDER_NAME                        VARCHAR2(240),
  PRE_NAME_ADJUNCT                  VARCHAR2(30),
  PROJECTED_START_DATE              DATE,
  REHIRE_AUTHORIZOR                 VARCHAR2(60),
  REHIRE_RECOMMENDATION             VARCHAR2(30),
  RESUME_EXISTS                     VARCHAR2(30),
  RESUME_LAST_UPDATED               DATE,
  SECOND_PASSPORT_EXISTS            VARCHAR2(30),
  STUDENT_STATUS                    VARCHAR2(30),
  WORK_SCHEDULE                     VARCHAR2(30),
  PER_INFORMATION21                 VARCHAR2(150),
  PER_INFORMATION22                 VARCHAR2(150),
  PER_INFORMATION23                 VARCHAR2(150),
  PER_INFORMATION24                 VARCHAR2(150),
  PER_INFORMATION25                 VARCHAR2(150),
  PER_INFORMATION26                 VARCHAR2(150),
  PER_INFORMATION27                 VARCHAR2(150),
  PER_INFORMATION28                 VARCHAR2(150),
  PER_INFORMATION29                 VARCHAR2(150),
  PER_INFORMATION30                 VARCHAR2(150),
  REHIRE_REASON                     VARCHAR2(60),
  BENEFIT_GROUP_ID                  NUMBER,
  RECEIPT_OF_DEATH_CERT_DATE        DATE,
  COORD_BEN_MED_PLN_NO              VARCHAR2(30),
  COORD_BEN_NO_CVG_FLAG             VARCHAR2(30),
  COORD_BEN_MED_EXT_ER              VARCHAR2(80),
  COORD_BEN_MED_PL_NAME             VARCHAR2(80),
  COORD_BEN_MED_INSR_CRR_NAME       VARCHAR2(80),
  COORD_BEN_MED_INSR_CRR_IDENT      VARCHAR2(80),
  COORD_BEN_MED_CVG_STRT_DT         DATE,
  COORD_BEN_MED_CVG_END_DT          DATE,
  USES_TOBACCO_FLAG                 VARCHAR2(30),
  DPDNT_ADOPTION_DATE               DATE,
  DPDNT_VLNTRY_SVCE_FLAG            VARCHAR2(30),
  ORIGINAL_DATE_OF_HIRE             DATE,
  town_of_birth                     varchar2(90),
  region_of_birth                   varchar2(90),
  country_of_birth                  varchar2(90),
  global_person_id                  varchar2(30),
  party_id                          number(15),
  npw_number                        varchar2(30),
  current_npw_flag                  varchar2(30),
  global_name                       varchar2(240), -- #3889584
  local_name                        varchar2(240)
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
g_api_dml  boolean;                               -- Global api dml status
g_tab_nam constant varchar2(30) :='PER_ALL_PEOPLE_F';
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function will return the current g_api_dml private global
--   boolean status.
--   The g_api_dml status determines if at the time of the function
--   being executed if a dml statement (i.e. INSERT, UPDATE or DELETE)
--   is being issued from within an api.
--   If the status is TRUE then a dml statement is being issued from
--   within this entity api.
--   This function is primarily to support database triggers which
--   need to maintain the object_version_number for non-supported
--   dml statements (i.e. dml statement issued outside of the api layer).
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   None.
--
-- Post Success:
--   Processing continues.
--   If the function returns a TRUE value then, dml is being executed from
--   within this api.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is called when a constraint has been violated (i.e.
--   The exception hr_api.check_integrity_violated,
--   hr_api.parent_integrity_violated, hr_api.child_integrity_violated or
--   hr_api.unique_integrity_violated has been raised).
--   The exceptions can only be raised as follows:
--   1) A check constraint can only be violated during an INSERT or UPDATE
--      dml operation.
--   2) A parent integrity constraint can only be violated during an
--      INSERT or UPDATE dml operation.
--   3) A child integrity constraint can only be violated during an
--      DELETE dml operation.
--   4) A unique integrity constraint can only be violated during INSERT or
--      UPDATE dml operation.
--
-- Pre Conditions:
--   1) Either hr_api.check_integrity_violated,
--      hr_api.parent_integrity_violated, hr_api.child_integrity_violated or
--      hr_api.unique_integrity_violated has been raised with the subsequent
--      stripping of the constraint name from the generated error message
--      text.
--   2) Standalone validation test which correspond with a constraint error.
--
-- In Arguments:
--   p_constraint_name is in upper format and is just the constraint name
--   (e.g. not prefixed by brackets, schema owner etc).
--
-- Post Success:
--   Development dependant.
--
-- Post Failure:
--   Developement dependant.
--
-- Developer Implementation Notes:
--   For each constraint being checked the hr system package failure message
--   has been generated as a template only. These system error messages should
--   be modified as required (i.e. change the system failure message to a user
--   friendly defined error message).
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to populate the g_old_rec record with the current
--   row from the database for the specified primary key provided that the
--   primary key exists and is valid and does not already match the current
--   g_old_rec.
--   The function will always return a TRUE value if the g_old_rec is
--   populated with the current row. A FALSE value will be returned if all of
--   the primary key arguments are null.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--
-- Post Success:
--   A value of TRUE will be returned indiciating that the g_old_rec is
--   current.
--   A value of FALSE will be returned if all of the primary key arguments
--   have a null value (this indicates that the row has not be inserted into
--   the Schema), and therefore could never have a corresponding row.
--
-- Post Failure:
--   A failure can only occur under two circumstances:
--   1) The primary key is invalid (i.e. a row does not exist for the
--      specified primary key values).
--   2) If an object_version_number exists but is NOT the same as the current
--      g_old_rec value.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function api_updating
  (p_effective_date		in date,
   p_person_id		in number,
   p_object_version_number	in number
  ) Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_del_modes >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to determine what datetrack delete modes are
--   allowed as of the effective date for this entity. The procedure will
--   return a corresponding Boolean value for each of the delete modes
--   available where TRUE indicates that the corresponding delete mode is
--   available.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_effective_date
--     Specifies the date at which the datetrack modes will be operated on.
--   p_base_key_value
--     Specifies the primary key value for this datetrack entity.
--     (E.g. For this entity the assignment of the argument would be:
--           p_base_key_value = :person_id).
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Failure might occur if for the specified effective date and primary key
--   value a row doesn't exist.
--
-- Developer Implementation Notes:
--   This procedure could require changes if this entity has any sepcific
--   delete restrictions.
--   For example, this entity might disallow the datetrack delete mode of
--   ZAP. To implement this you would have to set and return a Boolean value
--   of FALSE after the call to the dt_api.find_dt_del_modes procedure.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure find_dt_del_modes
	(p_effective_date	in  date,
	 p_base_key_value	in  number,
	 p_zap		 out nocopy boolean,
	 p_delete	 out nocopy boolean,
	 p_future_change out nocopy boolean,
	 p_delete_next_change out nocopy boolean);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_upd_modes >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to determine what datetrack update modes are
--   allowed as of the effective date for this entity. The procedure will
--   return a corresponding Boolean value for each of the update modes
--   available where TRUE indicates that the corresponding update mode
--   is available.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_effective_date
--     Specifies the date at which the datetrack modes will be operated on.
--   p_base_key_value
--     Specifies the primary key value for this datetrack entity.
--     (E.g. For this entity the assignment of the argument would be:
--           p_base_key_value = :person_id).
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Failure might occur if for the specified effective date and primary key
--   value a row doesn't exist.
--
-- Developer Implementation Notes:
--   This procedure could require changes if this entity has any sepcific
--   delete restrictions.
--   For example, this entity might disallow the datetrack update mode of
--   UPDATE. To implement this you would have to set and return a Boolean
--   value of FALSE after the call to the dt_api.find_dt_upd_modes procedure.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure find_dt_upd_modes
	(p_effective_date	in  date,
	 p_base_key_value	in  number,
	 p_correction	 out nocopy boolean,
	 p_update	 out nocopy boolean,
	 p_update_override out nocopy boolean,
	 p_update_change_insert out nocopy boolean);
--
-- ----------------------------------------------------------------------------
-- |------------------------< upd_effective_end_date >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure will update the specified datetrack row with the
--   specified new effective end date. The object version number is also
--   set to the next object version number. DateTrack modes which call
--   this procedure are: UPDATE, UPDATE_CHANGE_INSERT,
--   UPDATE_OVERRIDE, DELETE, FUTURE_CHANGE and DELETE_NEXT_CHANGE.
--   This is an internal datetrack maintenance procedure which should
--   not be modified in anyway.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_new_effective_end_date
--     Specifies the new effective end date which will be set for the
--     row as of the effective date.
--   p_base_key_value
--     Specifies the primary key value for this datetrack entity.
--     (E.g. For this entity the assignment of the argument would be:
--           p_base_key_value = :person_id).
--
-- Post Success:
--   The specified row will be updated with the new effective end date and
--   object_version_number.
--
-- Post Failure:
--   Failure might occur if for the specified effective date and primary key
--   value a row doesn't exist.
--
-- Developer Implementation Notes:
--   This is an internal datetrack maintenance procedure which should
--   not be modified in anyway.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd_effective_end_date
	(p_effective_date		in date,
	 p_base_key_value		in number,
	 p_new_effective_end_date	in date,
	 p_validation_start_date	in date,
	 p_validation_end_date		in date,
         p_object_version_number       out nocopy number);
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Lck process for datetrack is complicated and comprises of the
--   following processing
--   The processing steps are as follows:
--   1) The row to be updated or deleted must be locked.
--      By locking this row, the g_old_rec record data type is populated.
--   2) If a comment exists the text is selected from hr_comments.
--   3) The datetrack mode is then validated to ensure the operation is
--      valid. If the mode is valid the validation start and end dates for
--      the mode will be derived and returned. Any required locking is
--      completed when the datetrack mode is validated.
--
-- Pre Conditions:
--   When attempting to call the lck procedure the object version number,
--   primary key, effective date and datetrack mode must be specified.
--
-- In Arguments:
--   p_effective_date
--     Specifies the date of the datetrack update operation.
--   p_datetrack_mode
--     Determines the datetrack update or delete mode.
--
-- Post Success:
--   On successful completion of the Lck process the row to be updated or
--   deleted will be locked and selected into the global data structure
--   g_old_rec.
--
-- Post Failure:
--   The Lck process can fail for three reasons:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_Api.Object_Locked exception.
--   2) The row which is required to be locked doesn't exist in the HR Schema.
--      This error is trapped and reported using the message name
--      'HR_7220_INVALID_PRIMARY_KEY'.
--   3) The row although existing in the HR Schema has a different object
--      version number than the object version number specified.
--      This error is trapped and reported using the message name
--      'HR_7155_OBJECT_INVALID'.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure lck
	(p_effective_date	 in  date,
	 p_datetrack_mode	 in  varchar2,
	 p_person_id	 in  number,
	 p_object_version_number in  number,
	 p_validation_start_date out nocopy date,
	 p_validation_end_date	 out nocopy date);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to turn attribute arguments into the record
--   structure g_rec_type.
--
-- Pre Conditions:
--   This is a private function and can only be called from the ins or upd
--   attribute processes.
--
-- In Arguments:
--
-- Post Success:
--   A returning record structure will be returned.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this function will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_person_id                     in number,
	p_effective_start_date          in date,
	p_effective_end_date            in date,
	p_business_group_id             in number,
	p_person_type_id                in number,
	p_last_name                     in varchar2,
	p_start_date                    in date,
	p_applicant_number              in varchar2,
	p_comment_id                    in number,
	p_comments                      in varchar2,
	p_current_applicant_flag        in varchar2,
	p_current_emp_or_apl_flag       in varchar2,
	p_current_employee_flag         in varchar2,
	p_date_employee_data_verified   in date,
	p_date_of_birth                 in date,
	p_email_address                 in varchar2,
	p_employee_number               in varchar2,
	p_expense_check_send_to_addres  in varchar2,
	p_first_name                    in varchar2,
	p_full_name                     in varchar2,
	p_known_as                      in varchar2,
	p_marital_status                in varchar2,
	p_middle_names                  in varchar2,
	p_nationality                   in varchar2,
	p_national_identifier           in varchar2,
	p_previous_last_name            in varchar2,
	p_registered_disabled_flag      in varchar2,
	p_sex                           in varchar2,
	p_title                         in varchar2,
	p_vendor_id                     in number,
	p_work_telephone                in varchar2,
	p_request_id                    in number,
	p_program_application_id        in number,
	p_program_id                    in number,
	p_program_update_date           in date,
	p_attribute_category            in varchar2,
	p_attribute1                    in varchar2,
	p_attribute2                    in varchar2,
	p_attribute3                    in varchar2,
	p_attribute4                    in varchar2,
	p_attribute5                    in varchar2,
	p_attribute6                    in varchar2,
	p_attribute7                    in varchar2,
	p_attribute8                    in varchar2,
	p_attribute9                    in varchar2,
	p_attribute10                   in varchar2,
	p_attribute11                   in varchar2,
	p_attribute12                   in varchar2,
	p_attribute13                   in varchar2,
	p_attribute14                   in varchar2,
	p_attribute15                   in varchar2,
	p_attribute16                   in varchar2,
	p_attribute17                   in varchar2,
	p_attribute18                   in varchar2,
	p_attribute19                   in varchar2,
	p_attribute20                   in varchar2,
	p_attribute21                   in varchar2,
	p_attribute22                   in varchar2,
	p_attribute23                   in varchar2,
	p_attribute24                   in varchar2,
	p_attribute25                   in varchar2,
	p_attribute26                   in varchar2,
	p_attribute27                   in varchar2,
	p_attribute28                   in varchar2,
	p_attribute29                   in varchar2,
	p_attribute30                   in varchar2,
	p_per_information_category      in varchar2,
	p_per_information1              in varchar2,
	p_per_information2              in varchar2,
	p_per_information3              in varchar2,
	p_per_information4              in varchar2,
	p_per_information5              in varchar2,
	p_per_information6              in varchar2,
	p_per_information7              in varchar2,
	p_per_information8              in varchar2,
	p_per_information9              in varchar2,
	p_per_information10             in varchar2,
	p_per_information11             in varchar2,
	p_per_information12             in varchar2,
	p_per_information13             in varchar2,
	p_per_information14             in varchar2,
	p_per_information15             in varchar2,
	p_per_information16             in varchar2,
	p_per_information17             in varchar2,
	p_per_information18             in varchar2,
	p_per_information19             in varchar2,
	p_per_information20             in varchar2,
	p_object_version_number         in number,
        p_suffix                        in varchar2,
        p_DATE_OF_DEATH                 in DATE,
        p_BACKGROUND_CHECK_STATUS       in varchar2,
        p_BACKGROUND_DATE_CHECK         in DATE,
        p_BLOOD_TYPE                    in varchar2,
        p_CORRESPONDENCE_LANGUAGE       in varchar2,
        p_FAST_PATH_EMPLOYEE            in varchar2,
        p_FTE_CAPACITY                  in NUMBER,
        p_HOLD_APPLICANT_DATE_UNTIL     in DATE,
        p_HONORS                        in varchar2,
        p_INTERNAL_LOCATION             in varchar2,
        p_LAST_MEDICAL_TEST_BY          in varchar2,
        p_LAST_MEDICAL_TEST_DATE        in DATE,
        p_MAILSTOP                      in varchar2,
        p_OFFICE_NUMBER                 in varchar2,
        p_ON_MILITARY_SERVICE           in varchar2,
        p_ORDER_NAME                    in varchar2,
        p_PRE_NAME_ADJUNCT              in varchar2,
        p_PROJECTED_START_DATE          in DATE,
        p_REHIRE_AUTHORIZOR             in varchar2,
        p_REHIRE_RECOMMENDATION         in varchar2,
        p_RESUME_EXISTS                 in varchar2,
        p_RESUME_LAST_UPDATED           in DATE,
        p_SECOND_PASSPORT_EXISTS        in varchar2,
        p_STUDENT_STATUS                in varchar2,
        p_WORK_SCHEDULE                 in varchar2,
        p_PER_INFORMATION21             in varchar2,
        p_PER_INFORMATION22             in varchar2,
        p_PER_INFORMATION23             in varchar2,
        p_PER_INFORMATION24             in varchar2,
        p_PER_INFORMATION25             in varchar2,
        p_PER_INFORMATION26             in varchar2,
        p_PER_INFORMATION27             in varchar2,
        p_PER_INFORMATION28             in varchar2,
        p_PER_INFORMATION29             in varchar2,
        p_PER_INFORMATION30             in varchar2,
        p_REHIRE_REASON                 in varchar2,
        p_BENEFIT_GROUP_ID              in number,
        p_RECEIPT_OF_DEATH_CERT_DATE    in date,
        p_COORD_BEN_MED_PLN_NO          in varchar2,
        p_COORD_BEN_NO_CVG_FLAG         in varchar2,
        p_coord_ben_med_ext_er          in varchar2,
        p_coord_ben_med_pl_name         in varchar2,
        p_coord_ben_med_insr_crr_name   in varchar2,
        p_coord_ben_med_insr_crr_ident  in varchar2,
        p_coord_ben_med_cvg_strt_dt     in date,
        p_coord_ben_med_cvg_end_dt      in date,
        p_USES_TOBACCO_FLAG             in varchar2,
        p_DPDNT_ADOPTION_DATE           in date,
        p_DPDNT_VLNTRY_SVCE_FLAG        in varchar2,
        p_ORIGINAL_DATE_OF_HIRE         in date,
        p_town_of_birth                   in  varchar2,
        p_region_of_birth                 in  varchar2,
        p_country_of_birth                in  varchar2,
        p_global_person_id                in  varchar2,
        p_party_id                        in  number,
        p_npw_number                      in  varchar2,
        p_current_npw_flag                in  varchar2,
        p_global_name                     in  varchar2, -- #3889584
        p_local_name                      in  varchar2
	 )
	Return g_rec_type;
--
end per_per_shd;

/
